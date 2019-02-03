#!/usr/bin/python3
# coding: utf-8
# https://faker.readthedocs.io/en/stable/index.html

from faker import Faker
import mysql.connector

fake = Faker('ja_JP')

cnx = mysql.connector.connect(user='sample', password='sample_password', host='127.0.0.1', database='sampledb')
cursor = cnx.cursor()

add_user = ("INSERT INTO users "
            "(name, email, zip, tel, credit_card_number) "
            "VALUES (%(name)s, %(email)s, %(zip)s, %(tel)s, %(credit_card_number)s)")

for i in range(100):
    profile = fake.profile(fields=None, sex=None)

    data_user = {
        'name': profile['name'],
        'email': profile['mail'],
        'zip': fake.zipcode(),
        'tel': fake.phone_number(),
        'credit_card_number': fake.credit_card_number(card_type=None)
    }

    cursor.execute(add_user, data_user)

    cnx.commit()

cursor.close()
cnx.close()
