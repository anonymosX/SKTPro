#!/bin/python3
from ebaysdk.trading import Connection as Trading
from ebaysdk.connection import ConnectionError
import csv
import random
from datetime import datetime
from pytz import timezone

def DigitalLeaveFeedback(CONFIG, UserID, OrderLineItemID, FeedbackContents):
  api = Trading(config_file=CONFIG, domain='api.ebay.com')
  FeedbacksCount = sum(1 for i in FeedbackContents)
  RandomFeedback = FeedbackContents[random.randint(0, FeedbacksCount - 1)]
  PositionFeedback = {'FeedbackInfo': {
    'CommentText': RandomFeedback,
    'CommentType': 'Positive',
    'TargetUser': UserID
  },
    'Shipped': 1,
    'OrderLineItemID': OrderLineItemID
  }
  try:
    api.execute('CompleteSale', PositionFeedback)
  except ConnectionError:
    print(f'Error, not leave feedback: {UserID}')
def DigitalComplete(FeedbackContents):
  PacificTime = datetime.now(timezone('US/Pacific')).strftime("%Y-%m-%d")
  Today = PacificTime.split('-')[2]
  with open('key.csv', 'r') as KEYS:
    ListKeys = [row for row in csv.DictReader(KEYS)]
  ListLeaveFeedback = []
  ListRemoveRow = []
  for i in range(0, sum(1 for i in ListKeys)):
    DaySold = ListKeys[i]['DATE SOLD']
    if DaySold != '':
#leave feedback cho item is over 1 day + mark as shipped:
      if int(Today) - int(DaySold.split("-")[2]) > 1 and ListKeys[i]['LEAVE FEEDBACK'] != 'Yes':
        ListLeaveFeedback.append(i)
#remove key used over 3 days
      if int(Today) - int(DaySold.split("-")[2]) > 4:
        ListRemoveRow.append(i)
#Leave PositionFeedback Digital User Purchase
  for i in ListLeaveFeedback:
    CONFIG = f"{ListKeys[i]['STATUS'].split(':')[1].split('|')[0]}.yaml"
    UserID = ListKeys[i]['STATUS'].split(':')[1].split('|')[1]
    LineID = ListKeys[i]['STATUS'].split(':')[1].split('|')[2]
    DigitalLeaveFeedback(CONFIG, UserID, LineID, FeedbackContents)
    ListKeys[i]['LEAVE FEEDBACK'] = 'Yes'
  for i in ListRemoveRow[::-1]:
    ListKeys.pop(i)
#update key.csv content
  with open('key.csv', 'w', newline='') as update:
    DTC = csv.DictWriter(update, fieldnames = ListKeys[0].keys())
    DTC.writeheader()
    DTC.writerows(ListKeys)
def ImportEbay(FeedbackContents,INVOICE,TRACK,LOGICSTICS):
  FeedbacksCount = sum(1 for i in FeedbackContents)
  CountTrack = sum(1 for i in OrderDetails)
  for i in range(0,CountTrack):
    if OrderDetails[i]['INVOICE'].split('|')[0][0:1] == 'U' or OrderDetails[i]['INVOICE'].split('|')[0][:1] == 'V':
      CONFIG = f'{INVOICE.split("|")[0]}.yaml'
      api = Trading(config_file = CONFIG, domain = 'api.ebay.com')
      UserID = INVOICE.split('|')[1]
      OrderLineItemID = INVOICE.split('|')[2]
      RandomFeedback = FeedbackContents[random.randint(0, FeedbacksCount - 1)]
      ImportTracking = {'FeedbackInfo':{
        'CommentText': RandomFeedback,
        'CommentType': 'Positive',
        'TargetUser': UserID
      },
        'OrderLineItemID': OrderLineItemID,
        'Shipment':{
          'ShipmentTrackingDetails':{
            'ShipmentTrackingNumber': TRACK,
            'ShippingCarrierUsed': LOGICSTICS
          }
        },
        'Shipped': 1
      }
      api.execute('CompleteSale',ImportTracking)
  DigitalComplete(FeedbackContents)

if __name__ == '__main__':
  FeedbackContents = []
  with open('feedback.csv', 'r') as fb:
    Feedback = [row for row in csv.DictReader(fb)]
  for i in range(0, sum(1 for a in Feedback)):
    FeedbackContents.append(Feedback[i]['CONTENT'])
  HEADER = ['PAYPAL', 'TRANSACTION ID', 'INVOICE', 'TRACK NUMBER', 'LOGICSTICS']
  with open('/root/track.csv', 'r', newline='') as TrackDetails:
    OrderDetails = [row for row in csv.DictReader(TrackDetails, fieldnames = HEADER)]
  for i in range(0, sum(1 for a in OrderDetails)):
    PAYPAL = OrderDetails[i]['PAYPAL']
    TRANSACTION = OrderDetails[i]['TRANSACTION ID']
    INVOICE = OrderDetails[i]['INVOICE']
    TRACK = OrderDetails[i]['TRACK NUMBER']
    LOGICSTICS = OrderDetails[i]['LOGICSTICS']
    if INVOICE.split("|")[0] == 'U' or INVOICE.split("|")[0] == 'V':
      ImportEbay(FeedbackContents, INVOICE, TRACK, LOGICSTICS)

