# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
genres = Genre.create([{name: 'Drama'},{name: 'Comedy'},{name: 'Action'},{name: 'Documentary'}])
movie_1 = Movie.create(name: 'Anchorman', image: 'test.png', genre_id: genres[1].id)
movie_1 = Movie.create(name: 'Spaceballs: The Movie', image: 'test.png', genre_id: genres[1].id)
movie_1 = Movie.create(name: 'Halo: Forward Unto Dawn', image: 'test.png', genre_id: genres[2].id)
movie_1 = Movie.create(name: '007: Casino Royale', image: 'test.png', genre_id: genres[2].id)
movie_1 = Movie.create(name: 'Supersize Me', image: 'test.png', genre_id: genres[3].id)
movie_1 = Movie.create(name: 'Her', image: 'test.png', genre_id: genres[0].id)