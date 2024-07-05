#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1\n"
  fi
  GET_APPOINTMENT
}

GET_APPOINTMENT() {
  echo -e "Welcome to My Salon, how can I help you?\n"

  # get services aveleable
  GET_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$GET_SERVICES" | while read SERVICES_ID BAR NAME; do
    echo "$SERVICES_ID) $NAME"
  done
  # ask for service
  read SERVICE_ID_SELECTED

  # if input is not a numbaer
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]+$ ]]; then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # get service name
    GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED' ")

    # get customers info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    #get customer phone
    GET_CUSTOMER_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # get customer name
    GET_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if customer phone not found
    if [[ -z $GET_CUSTOMER_PHONE ]]; then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      echo -e "\nWhat time would you like your $GET_SERVICE_NAME, $CUSTOMER_NAME?"
      INSERT_CUSTOMER_TABLE=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    else
      echo -e "\nWhat time would you like your $GET_SERVICE_NAME,$GET_CUSTOMER_NAME?"
    fi

    # Ask for customer what time they want
    read SERVICE_TIME
    echo -e "\nWhat time would you like your$GET_SERVICE_NAME?"
    echo -e "\nI have put you down for a$GET_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE' ")
    # get services id selected
    SERVICES_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED' ")

    # insert to appointment table
    SAVED_TO_TABLE_APPOINTMENTS=$($PSQL "INSERT INTO appointments(time, service_id, customer_id) VALUES('$SERVICE_TIME', '$SERVICES_ID_SELECTED', '$CUSTOMER_ID')")
    
  fi
}

MAIN_MENU
