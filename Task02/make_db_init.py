#!/usr/bin/env python3
import csv
import os

def generate_db_init_sql():
    """Генерирует SQL-скрипт для создания и заполнения базы данных"""
    
    sql_script = """-- SQLite database initialization script for movies rating database
-- Generated automatically by make_db_init.py

PRAGMA foreign_keys = OFF;

"""

    # Удаление существующих таблиц
    sql_script += """
-- Drop existing tables if they exist
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS users;

"""

    # Создание таблиц
    sql_script += """
-- Create tables
CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    year INTEGER,
    genres TEXT
);

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    gender TEXT,
    register_date TEXT,
    occupation TEXT
);

CREATE TABLE ratings (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    rating REAL NOT NULL,
    timestamp INTEGER NOT NULL
);

CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    tag TEXT NOT NULL,
    timestamp INTEGER NOT NULL
);

"""

    # Извлечение данных для таблицы movies ИЗ CSV
    sql_script += "-- Extract data for movies table FROM CSV\n"
    with open('movies.csv', 'r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        for row in reader:
            # Экранирование апострофов
            title = row['title'].replace("'", "''")
            genres = row['genres'].replace("'", "''")
            
            sql_script += f"INSERT INTO movies (id, title, year, genres) VALUES ({row['movieId']}, '{title}', NULL, '{genres}');\n"

    # Извлечение данных для таблицы users ИЗ TXT
    sql_script += "\n-- Extract data for users table FROM TXT\n"
    with open('users.txt', 'r', encoding='utf-8') as file:
        for line in file:
            fields = line.strip().split('|')
            if len(fields) >= 6:
                user_id, name, email, gender, register_date, occupation = fields[:6]
                # Экранирование специальных символов
                name = name.replace("'", "''")
                email = email.replace("'", "''")
                occupation = occupation.replace("'", "''")
                
                sql_script += f"INSERT INTO users (id, name, email, gender, register_date, occupation) VALUES ({user_id}, '{name}', '{email}', '{gender}', '{register_date}', '{occupation}');\n"

    # Извлечение данных для таблицы ratings ИЗ CSV
    sql_script += "\n-- Extract data for ratings table FROM CSV\n"
    with open('ratings.csv', 'r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        for i, row in enumerate(reader, 1):
            sql_script += f"INSERT INTO ratings (id, user_id, movie_id, rating, timestamp) VALUES ({i}, {row['userId']}, {row['movieId']}, {row['rating']}, {row['timestamp']});\n"

    # Извлечение данных для таблицы tags ИЗ CSV
    sql_script += "\n-- Extract data for tags table FROM CSV\n"
    with open('tags.csv', 'r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        for i, row in enumerate(reader, 1):
            tag = row['tag'].replace("'", "''")
            sql_script += f"INSERT INTO tags (id, user_id, movie_id, tag, timestamp) VALUES ({i}, {row['userId']}, {row['movieId']}, '{tag}', {row['timestamp']});\n"

    sql_script += "\nPRAGMA foreign_keys = ON;"
    
    return sql_script

def main():
    print("Generating SQL initialization script...")
    
    # Проверяем существование файлов данных
    required_files = [
        'movies.csv',
        'users.txt', 
        'ratings.csv',
        'tags.csv'
    ]
    
    for file_path in required_files:
        if not os.path.exists(file_path):
            print(f"Error: Required file {file_path} not found!")
            return
    
    # Генерируем SQL-скрипт
    sql_content = generate_db_init_sql()
    
    # Сохраняем в файл
    with open('db_init.sql', 'w', encoding='utf-8') as file:
        file.write(sql_content)
    
    print("SQL script 'db_init.sql' generated successfully!")

if __name__ == "__main__":
    main()