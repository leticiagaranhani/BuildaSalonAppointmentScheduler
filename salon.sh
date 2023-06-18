#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

SHOW_SERVICES() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "select service_id, name from services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

READ_SERVICE() {
  read SERVICE_ID_SELECTED
  AVAILABLE_SERVICE_ID=$($PSQL "select service_id from services where service_id = $SERVICE_ID_SELECTED")
  # if do not find service, ask for it again
  if [[ -z $AVAILABLE_SERVICE_ID ]]
  then
    SHOW_SERVICES "I could not find that service. What would you like today?"
    READ_SERVICE
  else
    # if find service, ask for phone number
    ASK_PHONE $AVAILABLE_SERVICE_ID
  fi
}

ASK_NAME() {
  echo -e "\nI don't have a record for that phone number, what's your name?"
  
  read CUSTOMER_NAME
  
  CUSTOMER_INSERT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")

  ASK_TIME $CUSTOMER_NAME
}

ASK_PHONE() {
  
  SERVICE_NAME=$($PSQL "select name from services where service_id = $AVAILABLE_SERVICE_ID") 
  
  echo -e "\nWhat's your phone number?"
  
  read CUSTOMER_PHONE
  
  CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE' limit 1")
  
  #echo "$CUSTOMER_NAME"

  # if do not find phone number, ask for name. Insert name and phone
  if [[ -z "$CUSTOMER_NAME" ]]
  then
  # insert name and phone
    ASK_NAME $CUSTOMER_PHONE
  else
  # if find phone number, ask to schedule service
    ASK_TIME $CUSTOMER_NAME 
  fi
}

ASK_TIME() {
  SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
  echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
  
  read SERVICE_TIME
  
  if [[ -z "$SERVICE_TIME" ]]
  then
    echo "SERVICE_TIME not filled"
  else
  #  set msg if service was inserted
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
    APPOINTMENT_INSERT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    if [[ $APPOINTMENT_INSERT == "INSERT 0 1" ]]
    then
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

SHOW_SERVICES "Welcome to My Salon, how can I help you?\n"
READ_SERVICE 
