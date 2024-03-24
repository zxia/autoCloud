 unset https_proxy
 unset http_proxy
 export PYTHONPATH=/deploy
 export work_dir=/deploy/
 export cli="bash -x /deploy/dp.sh"
 python main.py

