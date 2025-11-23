from tensorflow.keras.preprocessing.image import ImageDataGenerator
import os

BASE_DIR = r"D:/iLAB/iLab/dataset"
train_dir = os.path.join(BASE_DIR, "train")

datagen = ImageDataGenerator()
gen = datagen.flow_from_directory(
    train_dir,
    target_size=(224, 224),
    batch_size=32,
    class_mode="categorical"
)

print(gen.class_indices)
