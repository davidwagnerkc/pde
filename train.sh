# --trainer.max_steps=10
export CUDA_TF32_OVERRIDE=0
DATA_DIR="/home/davidwagner/data/"
python scripts/pderefiner_train.py \
    -c configs/kuramotosivashinsky1d.yaml \
    --data.data_dir $DATA_DIR \
    --data.num_workers 8 \
    --data.batch_size 128 \
    --trainer.strategy=ddp \
    --trainer.devices=8 \
    --trainer.max_epochs=50 \
    --lr_scheduler.max_epochs=50
