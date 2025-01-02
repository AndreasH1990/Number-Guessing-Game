#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$((1 + $RANDOM % 1000))
# echo $RANDOM_NUMBER

echo -e "Enter your username:"
read USERNAME

# Query the username
USERNAME_RESULT=$($PSQL "SELECT name,games_played,best_game FROM users WHERE name = '$USERNAME'")

if [[ $USERNAME_RESULT ]]
then

  # username found
  echo "$USERNAME_RESULT" | while IFS='|' read NAME GAMES_PLAYED BEST_GAME
      do
      echo -e "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
      done

else

  # create new user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name,games_played,best_game) VALUES('$USERNAME',0,0)")
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."

fi

TRY_NUMBER=0
GAMES_PLAYED_OLD=$($PSQL "SELECT games_played FROM users WHERE name='$USERNAME'")
GAMES_PLAYED_NOW=$(($GAMES_PLAYED_OLD + 1))
INSERT_NEW_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED_NOW WHERE name='$USERNAME'")
echo -e "Guess the secret number between 1 and 1000:"

while true
do
read GUESS

  # count try number one up
  TRY_NUMBER=$(($TRY_NUMBER + 1))
  
  # not an integer
  INT_CHECK='^[0-9]+$'
  if ! [[ $GUESS =~ $INT_CHECK ]]
    then
    echo -e "That is not an integer, guess again:"
    continue
  fi

  # too low
  if [[ $GUESS -lt $RANDOM_NUMBER ]]
    then
    echo -e "It's higher than that, guess again:"
  elif [[ $GUESS -gt $RANDOM_NUMBER ]]
    then
    echo -e "It's lower than that, guess again:"
  else
    echo -e "You guessed it in $TRY_NUMBER tries. The secret number was $RANDOM_NUMBER. Nice job!"
        BEST_GAME_OLD=$($PSQL "SELECT best_game FROM users WHERE name='$USERNAME'")
    if [[ $BEST_GAME_OLD -gt $TRY_NUMBER ]] || [[ $BEST_GAME_OLD -eq 0 ]]
      then
        INSERT_NEW_BEST_GAME=$($PSQL "UPDATE users SET best_game=$TRY_NUMBER WHERE name='$USERNAME'")
    fi
    break
  fi
done
