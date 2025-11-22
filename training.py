import os
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras import layers, models
from tensorflow.keras.optimizers import Adam
from sklearn.utils.class_weight import compute_class_weight
from tensorflow.keras.applications.efficientnet import EfficientNetB0, preprocess_input

# -------------------------------
# 1. Paths & basic config
# -------------------------------
BASE_DIR = r"D:/iLAB/iLab/dataset"

train_dir = os.path.join(BASE_DIR, "train")
val_dir   = os.path.join(BASE_DIR, "val")
test_dir  = os.path.join(BASE_DIR, "test")

IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS_HEAD = 5        # train classifier head first
EPOCHS_FINE = 10       # then fine-tune backbone
SEED = 42

# -------------------------------
# 2. Data generators (use preprocess_input, NOT rescale)
# -------------------------------

train_datagen = ImageDataGenerator(
    preprocessing_function=preprocess_input,
    rotation_range=15,
    width_shift_range=0.1,
    height_shift_range=0.1,
    zoom_range=0.1,
    shear_range=0.1,
    horizontal_flip=True,
    fill_mode="nearest"
)

val_datagen = ImageDataGenerator(
    preprocessing_function=preprocess_input
)

test_datagen = ImageDataGenerator(
    preprocessing_function=preprocess_input
)

train_gen = train_datagen.flow_from_directory(
    train_dir,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode="categorical",
    shuffle=True,
    seed=SEED
)

val_gen = val_datagen.flow_from_directory(
    val_dir,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode="categorical",
    shuffle=False
)

test_gen = test_datagen.flow_from_directory(
    test_dir,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode="categorical",
    shuffle=False
)

num_classes = train_gen.num_classes
print("Classes found:", train_gen.class_indices)

# -------------------------------
# 3. Class weights (handle imbalance)
# -------------------------------
y_train = train_gen.classes

class_weights_array = compute_class_weight(
    class_weight="balanced",
    classes=np.unique(y_train),
    y=y_train
)
class_weights = {i: w for i, w in enumerate(class_weights_array)}

print("Class weights:", class_weights)

# -------------------------------
# 4. Build EfficientNetB0 model
# -------------------------------
base_model = EfficientNetB0(
    include_top=False,
    weights="imagenet",
    input_shape=(IMG_SIZE[0], IMG_SIZE[1], 3)
)

# Phase 1: freeze backbone
base_model.trainable = False

inputs = layers.Input(shape=(IMG_SIZE[0], IMG_SIZE[1], 3))
x = base_model(inputs, training=False)
x = layers.GlobalAveragePooling2D()(x)
x = layers.Dropout(0.4)(x)
outputs = layers.Dense(num_classes, activation="softmax")(x)

model = models.Model(inputs, outputs)

model.compile(
    optimizer=Adam(learning_rate=1e-3),
    loss="categorical_crossentropy",
    metrics=["accuracy"]
)

model.summary()

checkpoint_path = r"D:/iLAB/best_eye_model.keras"

early_stopping = tf.keras.callbacks.EarlyStopping(
    monitor="val_loss",
    patience=3,
    restore_best_weights=True
)

model_checkpoint = tf.keras.callbacks.ModelCheckpoint(
    checkpoint_path,
    monitor="val_accuracy",
    save_best_only=True,
    mode="max",
    verbose=1
)

# -------------------------------
# 5. Train classifier head only
# -------------------------------
history_head = model.fit(
    train_gen,
    epochs=EPOCHS_HEAD,
    validation_data=val_gen,
    class_weight=class_weights,
    callbacks=[early_stopping, model_checkpoint]
)

# -------------------------------
# 6. Fine-tune: unfreeze top layers of EfficientNet
# -------------------------------
# Load best weights so far (optional but good)
model.load_weights(checkpoint_path)

base_model.trainable = True

# freeze lower layers, fine-tune only higher-level features
for layer in base_model.layers[:-40]:   # adjust 40 if you want more/less fine-tuning
    layer.trainable = False

model.compile(
    optimizer=Adam(learning_rate=1e-4),   # smaller LR for fine-tuning
    loss="categorical_crossentropy",
    metrics=["accuracy"]
)

print("Number of trainable layers:", len([l for l in model.layers if l.trainable]))

history_fine = model.fit(
    train_gen,
    epochs=EPOCHS_FINE,
    validation_data=val_gen,
    class_weight=class_weights,
    callbacks=[early_stopping, model_checkpoint]
)

# -------------------------------
# 7. Evaluate on test set
# -------------------------------
# load best model before final eval
model.load_weights(checkpoint_path)

test_loss, test_acc = model.evaluate(test_gen)
print(f"Test loss: {test_loss:.4f}, Test accuracy: {test_acc:.4f}")

# -------------------------------
# 8. Save final model
# -------------------------------
save_path = r"D:/iLAB/eye_disease_classifier.keras"
model.save(save_path)
print(f"Model saved as {save_path}")
