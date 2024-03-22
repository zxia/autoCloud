import shell
from pod import ServiceInfo


def create_service(service: str, item: ServiceInfo):
    return shell.exec_shell('echo "hello world!" > /root/hello.txt')


def update_service(service: str, item: ServiceInfo):
    return shell.exec_shell('echo "hello world!" > /root/hello.txt')


def destory_service(service: str, item: ServiceInfo):
    return shell.exec_shell('echo "hello world!" > /root/hello.txt')
