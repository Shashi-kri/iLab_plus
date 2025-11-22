import os
from tensorflow.keras.preprocessing.image import ImageDataGenerator, img_to_array, load_img

DATASET_DIR = 'iLab\dataset'
TARGET_COUNT = 900

# ✅ Only these folders will be augmented
AUGMENT_CLASSES = ["Subconjunctival Hemorrage",]

datagen = ImageDataGenerator(
    rotation_range=15,
    width_shift_range=0.15,
    height_shift_range=0.15,
    zoom_range=0.15,
    shear_range=0.15,
    horizontal_flip=True,
    brightness_range=(0.8, 1.2),
    fill_mode="nearest"
)

for cls in AUGMENT_CLASSES:
    folder = os.path.join(DATASET_DIR, cls)
    if not os.path.isdir(folder):
        print(f"[SKIP] Folder not found: {folder}")
        continue

    images = [f for f in os.listdir(folder) if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
    current_count = len(images)

    print(f"\nClass: {cls}")
    print(f"Current images: {current_count}")

    if current_count >= TARGET_COUNT:
        print("Already at or above target, skipping.")
        continue

    extra_needed = TARGET_COUNT - current_count
    print(f"Need to generate: {extra_needed} images")

    generated = 0

    # 🔁 Keep looping over original images until we reach TARGET_COUNT
    while generated < extra_needed:
        for img_name in images:
            if generated >= extra_needed:
                break

            img_path = os.path.join(folder, img_name)

            # load and convert to array
            img = load_img(img_path)
            x = img_to_array(img)
            x = x.reshape((1,) + x.shape)  # (1, h, w, c)

            prefix = os.path.splitext(img_name)[0]

            # 🔑 This creates a generator – we must CALL next() on it
            aug_iter = datagen.flow(
                x,
                batch_size=1,
                save_to_dir=folder,
                save_prefix=f"{prefix}_aug",
                save_format="jpg"
            )

            # generate ONE augmented image for this original
            next(aug_iter)
            generated += 1

            if generated % 50 == 0 or generated == extra_needed:
                print(f"Generated {generated}/{extra_needed} for {cls}")

    print(f"✅ Done: {cls} now has ~{current_count + generated} images")

print("\n🎉 Augmentation finished!")
