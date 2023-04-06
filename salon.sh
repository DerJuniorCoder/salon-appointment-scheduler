#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
# psql --username=freecodecamp --dbname=salon -c "SQL QUERY HERE"

echo -e "\n~~~~~~Special Salon Service~~~~~~~"
echo -e "\nWelcome to the salon how can I help you?"

SERVICES=$($PSQL "SELECT * FROM services")

MAIN_MENU() {
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi

  # Main Menu
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # Get Service
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  echo SERVICE NAME IS $SERVICE_NAME

  # Check for a valid input
  # if [[ $SERVICE_ID_SELECTED =~ ^[a-zA-Z]+$ ]]
  #   then
  #     MAIN_MENU "Bad input, enter a valid option"
  #   else
  #     SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  # fi

  # echo SERVICE NAME IS $SERVICE_NAME
  
  # if service doesn't exits
  if [[ -z $SERVICE_NAME || $SERVICE_ID_SELECTED =~ ^[a-zA-Z]+$ ]]
    then
      # Return to main menu
      MAIN_MENU "I could not find that service. What would you like today?"

    else
      # Proceed to the registration
      REGISTER $SERVICE_NAME
  fi
}

REGISTER() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # if phone is not on db
  if [[ -z $CUSTOMER_NAME ]]
    then
      # Get name & Time
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      echo -e "\nWhat time would you like your $1, $CUSTOMER_NAME?"
      read SERVICE_TIME

      # Insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]
        then
          echo Inserted Costumer $CUSTOMER_NAME with telephone number $CUSTOMER_PHONE
      fi

      # Insert appointment
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name='$1'")
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID)")

      # If insertion is correct 
      if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
        then
          echo -e “I have put you down for a $1 at $SERVICE_TIME, $CUSTOMER_NAME.”
      fi
      
    else
      # if phone is already on db
      echo -e "\nWhat time would you like your $1,$CUSTOMER_NAME?"
      read SERVICE_TIME

      # Insert appointment
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name='$1'")
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID)")

      # If insertion is correct 
      if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
        then
          echo -e “I have put you down for a $1 at $SERVICE_TIME, $CUSTOMER_NAME.”
      fi


  fi
}




MAIN_MENU



