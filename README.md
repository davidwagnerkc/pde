Collection of various PDE related work. 

# PDE-Refiner Slides

Use `quarto preview pde-refiner.ipynb` to preview the Reveal.js slides in a browser window while making changes.

# PDE-Refiner Repro

Notes on attempt to reproduce PDE-Refiner for Kuramoto-Sivashinsky. Was not able to reproduce > 90s rollout with > 0.8 correlation, but this is a start.

### Generate Training Data

To generate the data download this repo and install the conda environment: https://github.com/brandstetter-johannes/LPSDA

Then run `./generate-ks.sh`. This takes 3 days to run on a M2 Pro. Then make a copy of the training dataset for each GPU you will train on.

### Training

Download https://github.com/pdearena/pdearena, install the conda environement inside of `docker/` then add this to training config for Kuramoto-Sivashinsky so we get checkpoints:
```
+    - class_path: pytorch_lightning.callbacks.ModelCheckpoint
+      init_args:
+        monitor: 'train/loss_mean'
+        save_top_k: 1
+        verbose: True
+        save_last: True
+        dirpath: ${trainer.default_root_dir}/ckpts
+        filename: "epoch_{epoch:03d}"
+        auto_insert_metric_name: False
+        save_on_train_epoch_end: True
```

Then can run `./train.sh` this takes 3 hours on 8x A100s or 2 days on V100.

### Evaluation

Can use `evaluation.ipynb` to save ground truth and inference tensors to disk then use `poster_plots.ipynb` to generate the comparison images and correlation plots.

For testing add this diff to pdearena to force using the train dataset for testing (they use 140 for training and the rest of the trajectory for test).

```
             with h5py.File(path, "r") as f:
-                data_h5 = f[self.mode]
+                data_h5 = f["train"] # f[self.mode]
                 data_key = [k for k in data_h5.keys() if k.startswith("pde_")][0]
                 data = {
                     "u": torch.tensor(data_h5[data_key][:].astype(self.dtype)),
@@ -140,7 +140,7 @@ def _valid_filter(fname):

 def _test_filter(fname):
-    return "_test_" in fname and "h5" in fname
+    return "_train_" in fname and "h5" in fname
```

