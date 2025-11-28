import os
import shutil
import random

# 🔧 CONFIG
DATASET_DIR = r"iLab\dataset"   # change if needed
CLASS_NAMES = ["cataract", "Conjectivites", "Eyelid", "Normal Eye", "Pterygium"]  # folder names
TRAIN_SPLIT = 0.7
VAL_SPLIT = 0.15   # test will be 1 - train - val

IMAGE_EXTS = (".jpg", ".jpeg", ".png", ".bmp")  # allowed image types

random.seed(42)  # for reproducibility

# 🔹 Create output folders: train, val, test
splits = ["train", "val", "test"]
for split in splits:
    split_dir = os.path.join(DATASET_DIR, split)
    os.makedirs(split_dir, exist_ok=True)
    for cls in CLASS_NAMES:
        os.makedirs(os.path.join(split_dir, cls), exist_ok=True)

for cls in CLASS_NAMES:
    class_dir = os.path.join(DATASET_DIR, cls)
    if not os.path.isdir(class_dir):
        print(f"[WARN] Class folder not found, skipping: {class_dir}")
        continue

    # list all image files
    files = [
        f for f in os.listdir(class_dir)
        if f.lower().endswith(IMAGE_EXTS)
    ]
    random.shuffle(files)

    n_total = len(files)
    n_train = int(n_total * TRAIN_SPLIT)
    n_val = int(n_total * VAL_SPLIT)
    n_test = n_total - n_train - n_val  # rest goes to test

    train_files = files[:n_train]
    val_files = files[n_train:n_train + n_val]
    test_files = files[n_train + n_val:]

    print(f"\nClass: {cls}")
    print(f" Total: {n_total}")
    print(f"  Train: {len(train_files)}, Val: {len(val_files)}, Test: {len(test_files)}")

    # helper to move files
    def move_files(file_list, split_name):
        for fname in file_list:
            src = os.path.join(class_dir, fname)
            dst = os.path.join(DATASET_DIR, split_name, cls, fname)
            # move file
            shutil.move(src, dst)

    move_files(train_files, "train")
    move_files(val_files, "val")
    move_files(test_files, "test")

print("\n✅ Done! Dataset has been split into train/val/test.")
