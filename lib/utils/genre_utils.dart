int genreToId(String genre) {
  switch (genre) {
    case "ACTION":
      {
        return 28;
      }
    case "ADVENTURE":
      {
        return 12;
      }
    case "ANIMATION":
      {
        return 16;
      }
    case "COMEDY":
      {
        return 35;
      }
    case "CRIME":
      {
        return 80;
      }
    case "DOCUMENTARY":
      {
        return 99;
      }
    case "DRAMA":
      {
        return 18;
      }
    case "FAMILY":
      {
        return 10751;
      }
    case "FANTASY":
      {
        return 14;
      }
    case "HISTORY":
      {
        return 36;
      }
    case "HORROR":
      {
        return 27;
      }
    case "MUSIC":
      {
        return 10402;
      }
    case "MYSTERY":
      {
        return 9648;
      }
    case "ROMANCE":
      {
        return 10749;
      }
    case "SCIENCE FICTION":
      {
        return 878;
      }
    case "THRILLER":
      {
        return 53;
      }
    case "TV MOVIE":
      {
        return 10770;
      }
    case "WAR":
      {
        return 10752;
      }
    case "WESTERN":
      {
        return 37;
      }
  }
  return -1;
}
