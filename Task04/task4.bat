#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма, который они ценили. В списке оставить первые 100 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT 
    CASE WHEN u1.name < u2.name THEN u1.name ELSE u2.name END AS user1_name,
    CASE WHEN u1.name < u2.name THEN u2.name ELSE u1.name END AS user2_name,
    m.title AS movie_title
FROM ratings r1
JOIN ratings r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id
JOIN users u1 ON r1.user_id = u1.id
JOIN users u2 ON r2.user_id = u2.id
JOIN movies m ON r1.movie_id = m.id
ORDER BY user1_name, user2_name, movie_title
LIMIT 100;"
echo " "

echo "2. Найти 10 самых свежих оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH latest_ratings AS (
    SELECT 
        r.id,
        m.title AS movie_title,
        u.name AS user_name,
        r.rating,
        date(datetime(r.timestamp, 'unixepoch')) AS review_date,
        r.timestamp AS ts,
        ROW_NUMBER() OVER (PARTITION BY r.user_id ORDER BY r.timestamp DESC) AS rn
    FROM ratings r
    JOIN movies m ON r.movie_id = m.id
    JOIN users u ON r.user_id = u.id
)
SELECT 
    movie_title,
    user_name,
    rating,
    review_date
FROM latest_ratings
WHERE rn = 1
ORDER BY ts DESC
LIMIT 10;"
echo " "

echo "3. Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке \"Рекомендуем\" для фильмов должно быть написано \"Да\" или \"Нет\"."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH movie_ratings AS (
    SELECT 
        m.id,
        m.title,
        m.year,
        AVG(r.rating) AS avg_rating
    FROM movies m
    JOIN ratings r ON m.id = r.movie_id
    GROUP BY m.id, m.title, m.year
),
min_max_ratings AS (
    SELECT 
        MIN(avg_rating) AS min_rating,
        MAX(avg_rating) AS max_rating
    FROM movie_ratings
)
SELECT 
    mr.title,
    mr.year,
    mr.avg_rating,
    CASE 
        WHEN mr.avg_rating = (SELECT max_rating FROM min_max_ratings) THEN 'Да'
        ELSE 'Нет'
    END AS Рекомендуем
FROM movie_ratings mr
WHERE mr.avg_rating = (SELECT min_rating FROM min_max_ratings)
   OR mr.avg_rating = (SELECT max_rating FROM min_max_ratings)
ORDER BY mr.year, mr.title;"
echo " "

echo "4. Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-женщины в период с 2010 по 2012 год."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT 
    COUNT(*) AS количество_оценок,
    AVG(r.rating) AS средняя_оценка
FROM ratings r
JOIN users u ON r.user_id = u.id
WHERE u.gender = 'female'
  AND CAST(strftime('%Y', datetime(r.timestamp, 'unixepoch')) AS INTEGER) BETWEEN 2010 AND 2012;"
echo " "

echo "5. Составить список фильмов с указанием их средней оценки и места в рейтинге по средней оценке. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH movie_ratings AS (
    SELECT 
        m.id,
        m.title,
        m.year,
        AVG(r.rating) AS avg_rating,
        RANK() OVER (ORDER BY AVG(r.rating) DESC) AS rating_rank
    FROM movies m
    JOIN ratings r ON m.id = r.movie_id
    GROUP BY m.id, m.title, m.year
)
SELECT 
    title,
    year,
    avg_rating,
    rating_rank AS место_в_рейтинге
FROM movie_ratings
ORDER BY year, title
LIMIT 20;"
echo " "

echo "6. Вывести список из 10 последних зарегистрированных пользователей в формате \"Фамилия Имя|Дата регистрации\" (сначала фамилия, потом имя)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT 
    SUBSTR(name, INSTR(name, ' ') + 1) || ' ' || SUBSTR(name, 1, INSTR(name, ' ') - 1) || '|' || register_date AS user_info
FROM users
ORDER BY register_date DESC
LIMIT 10;"
echo " "

echo "7. С помощью рекурсивного CTE составить таблицу умножения для чисел от 1 до 10. Должен получиться один столбец следующего вида: 1x1=1, 1x2=2, ..., 10x10=100."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE multiplication_table AS (
    SELECT 1 AS a, 1 AS b, 1 AS result
    UNION ALL
    SELECT 
        CASE WHEN b = 10 THEN a + 1 ELSE a END,
        CASE WHEN b = 10 THEN 1 ELSE b + 1 END,
        CASE WHEN b = 10 THEN (a + 1) * 1 ELSE a * (b + 1) END
    FROM multiplication_table
    WHERE a < 10 OR (a = 10 AND b < 10)
)
SELECT a || 'x' || b || '=' || result AS multiplication
FROM multiplication_table
ORDER BY a, b;"
echo " "

echo "8. С помощью рекурсивного CTE выделить все жанры фильмов, имеющиеся в таблице movies (каждый жанр в отдельной строке)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split_genres AS (
    SELECT 
        id,
        genres,
        CASE 
            WHEN INSTR(genres, '|') > 0 THEN SUBSTR(genres, 1, INSTR(genres, '|') - 1)
            ELSE genres
        END AS genre,
        CASE 
            WHEN INSTR(genres, '|') > 0 THEN SUBSTR(genres, INSTR(genres, '|') + 1)
            ELSE ''
        END AS remaining
    FROM movies
    WHERE genres IS NOT NULL AND genres != ''
    UNION ALL
    SELECT 
        id,
        remaining AS genres,
        CASE 
            WHEN INSTR(remaining, '|') > 0 THEN SUBSTR(remaining, 1, INSTR(remaining, '|') - 1)
            ELSE remaining
        END AS genre,
        CASE 
            WHEN INSTR(remaining, '|') > 0 THEN SUBSTR(remaining, INSTR(remaining, '|') + 1)
            ELSE ''
        END AS remaining
    FROM split_genres
    WHERE remaining != ''
)
SELECT DISTINCT genre
FROM split_genres
WHERE genre != ''
ORDER BY genre;"
echo " "

