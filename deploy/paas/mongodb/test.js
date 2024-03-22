db = connect( 'mongodb://root:iuKEauxtab@192.168.0.102:31191/?directConnection=true&authMechanism=DEFAULT' );
db.movies.insertMany( [
   {
      title: 'Titanic',
      year: 1997,
      genres: [ 'Drama', 'Romance' ]
   },
   {
      title: 'Spirited Away',
      year: 2001,
      genres: [ 'Animation', 'Adventure', 'Family' ]
   },
   {
      title: 'Casablanca',
      genres: [ 'Drama', 'Romance', 'War' ]
   }
] )