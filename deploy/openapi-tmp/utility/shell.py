import datetime
import subprocess
import time


def exec_shell(cmd: str, cwd=None, timeout=None, shell=True):
    try:
        if shell:
            cmd_list = cmd
        if timeout:
            end_time = datetime.datetime.now() \
                       + datetime.timedelta(seconds=timeout)

        sub = subprocess.Popen(cmd_list, cwd=cwd, stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                               shell=shell, bufsize=4096)

        while sub.poll() is None:
            time.sleep(1)
            if timeout:
                if end_time <= datetime.datetime.now():
                    print("Action execute_command Timeout")
                    return None
    except Exception as e:
        print(e)
        return None
    print("The execute_command return code is: " + str(sub.returncode))
    return sub
