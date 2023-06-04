from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class User(BaseModel):
    id: int
    name = "John Doe"
    signup_ts: datetime | None = None
    friends: list[int] = []


external_data = {
    "id": "123",
    "signup_ts": "2022-09-27 12:22",
    "friends": [1, "2", b"3"],
}

user = User(**external_data)
print(user)
print(user.id)


def get_full_name(first_name: str, last_name: str):
    full_name = first_name.title() + " " + last_name.title()
    return full_name


def get_name_with_age(name: str, age: int):
    name_with_age = name + "is this old " + str(age)
    return name_with_age


def process_items(items: list[str]):
    for item in items:
        print(item)


def process_items(items_t: tuple[int, int, str], items_s: set[bytes]):
    return items_t, items_s


def process_items(prices: dict[str, float]):
    for item_name, item_price in prices.items():
        print(item_name)
        print(item_price)


def process_items(item: int | str):
    print(item)


def say_hi(name: Optional[str] = None):
    if name is not None:
        print(f"hey {name}!")
    else:
        print("hellow world !")


class Person:
    def __init__(self, name: str):
        self.name = name


def get_person_name(one_person: Person):
    return one_person.name


print(get_full_name("jackey", "xia"))
print(get_name_with_age("jackeyxia", 18))
