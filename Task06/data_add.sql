-- 1. Добавление новых пользователей
INSERT INTO users (name, email, gender, register_date, occupation_id)
VALUES 
('Альвина Кучина', 'alvina.kuchina@example.com', 'male', date('now'), 
    (SELECT id FROM occupations WHERE name = 'student')),
('Максим Ларькин', 'maksim.larkin@example.com', 'male', date('now'), 
    (SELECT id FROM occupations WHERE name = 'student')),
('Максим Лузин', 'maksim.luzin@example.com', 'male', date('now'), 
    (SELECT id FROM occupations WHERE name = 'student')),
('Михаил Марьин', 'mikhail.marin@example.com', 'male', date('now'), 
    (SELECT id FROM occupations WHERE name = 'student')),
('Ильдар Кармышев', 'ildar.karmishev@example.com', 'male', date('now'), 
    (SELECT id FROM occupations WHERE name = 'student'));


INSERT INTO movies (title, year)
VALUES 
('Варкрафт', 2016),
('Тихоокеанский рубеж', 2013),
('Вышка', 2022);


INSERT INTO movies_genres (movie_id, genre_id)
VALUES 
-- Варкрафт: Fantasy, Action, Adventure
((SELECT id FROM movies WHERE title = 'Варкрафт'), 
 (SELECT id FROM genres WHERE name = 'Fantasy')),
((SELECT id FROM movies WHERE title = 'Варкрафт'), 
 (SELECT id FROM genres WHERE name = 'Action')),
((SELECT id FROM movies WHERE title = 'Варкрафт'), 
 (SELECT id FROM genres WHERE name = 'Adventure')),

-- Тихоокеанский рубеж: Action, Adventure, Sci-Fi
((SELECT id FROM movies WHERE title = 'Тихоокеанский рубеж'), 
 (SELECT id FROM genres WHERE name = 'Action')),
((SELECT id FROM movies WHERE title = 'Тихоокеанский рубеж'), 
 (SELECT id FROM genres WHERE name = 'Adventure')),
((SELECT id FROM movies WHERE title = 'Тихоокеанский рубеж'), 
 (SELECT id FROM genres WHERE name = 'Sci-Fi')),

-- Вышка: Thriller
((SELECT id FROM movies WHERE title = 'Вышка'), 
 (SELECT id FROM genres WHERE name = 'Thriller'));

-- 4. Добавление отзывов
INSERT INTO ratings (user_id, movie_id, rating, timestamp)
VALUES 
((SELECT id FROM users WHERE email = 'maksim.larkin@example.com'), 
 (SELECT id FROM movies WHERE title = 'Варкрафт'), 4.5, strftime('%s', 'now')),
((SELECT id FROM users WHERE email = 'maksim.larkin@example.com'), 
 (SELECT id FROM movies WHERE title = 'Тихоокеанский рубеж'), 5.0, strftime('%s', 'now')),
((SELECT id FROM users WHERE email = 'maksim.larkin@example.com'), 
 (SELECT id FROM movies WHERE title = 'Вышка'), 4.0, strftime('%s', 'now'));

-- 5. Добавление тегов
INSERT INTO tags (user_id, movie_id, tag, timestamp)
VALUES 
((SELECT id FROM users WHERE email = 'maksim.larkin@example.com'), 
 (SELECT id FROM movies WHERE title = 'Варкрафт'), 'Эпическая фэнтези сага', strftime('%s', 'now')),
((SELECT id FROM users WHERE email = 'maksim.larkin@example.com'), 
 (SELECT id FROM movies WHERE title = 'Тихоокеанский рубеж'), 'Фильм про борьбу человечества с кайдзю', strftime('%s', 'now')),
((SELECT id FROM users WHERE email = 'maksim.larkin@example.com'), 
 (SELECT id FROM movies WHERE title = 'Вышка'), 'Невероятно захватывающий триллер', strftime('%s', 'now'));