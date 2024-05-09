#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Your script should randomly generate a number that users have to guess
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
#echo $SECRET_NUMBER

# When you run your script, you should prompt the user for a username
echo "Enter your username: " 
read USERNAME

NAME=$($PSQL"SELECT name FROM users WHERE name = '$USERNAME'")



if [[ -z $NAME ]]
then
# if the username has not been used before, you should print Welcome, <username>! It looks like this is your first time here.
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_NAME=$($PSQL"INSERT INTO users(name) VALUES('$USERNAME')")
else
  USER_ID=$($PSQL"SELECT user_id FROM users WHERE name = '$USERNAME'")
  # If the username has been used before with <username> being a users name from the database <games_played> being the total number of games that user has played
  GAMES_PLAYED=$($PSQL"SELECT COUNT(game_id) FROM games_played WHERE user_id = $USER_ID")
  # and <best_game> being the fewest number of guesses it took that user to win the game  
  BEST_GAME=$($PSQL"SELECT MIN(guesses_taken_to_win) FROM games_played WHERE user_id = $USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
  
# The next line printed should be Guess the secret number between 1 and 1000: and input from the user should be read
echo "Guess the secret number between 1 and 1000:"    
read GUESS

NUMBER_OF_GUESSES=1

# until user guess a secret_number, continue asking a guess
until [[ $GUESS == $SECRET_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    # If anything other than an integer is input as a guess
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      if [[ $GUESS -lt $SECRET_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      fi
      ((NUMBER_OF_GUESSES++))      
    fi
  fi
  read GUESS
done

USER_ID=$($PSQL"SELECT user_id FROM users WHERE name = '$USERNAME'")
INSERT_GAME=$($PSQL"INSERT INTO games_played(user_id, guesses_taken_to_win) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
# When the secret number is guessed print following and finish running
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
