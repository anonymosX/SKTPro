#!/bin/python3
import csv
from ebaysdk.trading import Connection as Trading
from datetime import datetime, timedelta
import os

def Stock(SKU):
    with open('key.csv', mode = 'r', newline = '') as KEYS:
        ListKeys = [raw for raw in csv.DictReader(KEYS)]
    TotalKeys = sum(1 for raw in ListKeys)
    Stock = 0
    for i in range(0, TotalKeys):
        if ListKeys[i]['SKU'] == SKU and ListKeys[i]['STATUS'] == '':
            Stock += 1
    return Stock
def Sku(SKU):
    with open('sku.csv', mode ='r') as file:
        ListSKU = [row for row in csv.DictReader(file)]
    for i in range(0, sum(1 for x in ListSKU)):
        if ListSKU[i]['SKU'] == SKU:
            title = ListSKU[i]['TITLE']
            link = ListSKU[i]['LINK']
            type = ListSKU[i]['TYPE']
            active = ListSKU[i]['ACTIVE']
            break
        else:
            title = None
            link = None
            type = None
            active = None
    return title, type, link, active
def AutoSendKeys(config):
    #(AutoSendKey and filled Marked as sent key in key.csv)
    api = Trading(config_file=config, domain='api.ebay.com')
    Today = datetime.now()
    response = api.execute('GetOrders',{'CreateTimeFrom': Today - timedelta(days=1),'CreateTimeTo': Today,'OrderStatus': 'Completed'})
    try:
        Order = response.reply.OrderArray.Order
    except AttributeError:
        Order = None
    if Order != None:
        for order in Order:
            #Check
            for Transaction_obj in order.TransactionArray.Transaction:
                Account = str(config).replace('.yaml','')
                OrderID = order.OrderID
                try:
                    VariantSKU = Transaction_obj.Variation.SKU
                except AttributeError:
                    VariantSKU = ''
                if VariantSKU == '':
                    try:
                        SKU = Transaction_obj.Item.SKU
                    except AttributeError:
                        SKU =''
                else:
                    SKU = VariantSKU
                UserID = order.BuyerUserID
                Quantity = int(Transaction_obj.QuantityPurchased)
                INVOICE  = f'{Account}|{UserID}|{OrderID}'
                FILTER = SKU.split('|')[0]
                #DROPSHIP
                if FILTER == 'DI' and Sku(SKU)[0] != None:
                    with open('key.csv', mode = 'r',newline = '') as file:
                        ListKeys = [raw for raw in csv.DictReader(file)]
                    TotalKeys = sum(1 for raw in ListKeys)
                    OrderID_SentKeys = []
                    #Check OrderID nay de sent key chua(within file key stored)
                    for i in range(0, TotalKeys):
                        try:
                            OrderIDCheck = ListKeys[i]['STATUS'].split(':')[1].split('|')[2]
                        except IndexError:
                            OrderIDCheck = None
                        if OrderIDCheck != None:
                            OrderID_SentKeys.append(OrderIDCheck)
                    if OrderID not in OrderID_SentKeys:
                        if Stock(SKU) > Quantity:
                            Code = []
                            KEY = ''
                            print({INVOICE})
                            for i in range(0, TotalKeys):
                                if ListKeys[i]['SKU'] == SKU and ListKeys[i]['STATUS'] == '':
                                    Code.append(ListKeys[i]['KEY'])
                            for qtt in range(0, Quantity):
                                if (sum(1 for x in Code)) > 1:
                                    KEY += f' The code {qtt + 1} => {Code[qtt]}\n'
                                elif (sum(1 for x in Code)) == 1:
                                    KEY = Code[0]
                                for i in range(0, TotalKeys):
                                    if ListKeys[i]['KEY'] == Code[qtt]:
                                        ListKeys[i]['STATUS'] = f'USED:{INVOICE}'
                                        ListKeys[i]['DATE SOLD'] = f'{order.CreatedTime.strftime("%Y-%m-%d")}'
                                        with open('key.csv', 'w', newline='') as file:
                                            Update = csv.DictWriter(file, fieldnames = ListKeys[0].keys())
                                            Update.writeheader()
                                            Update.writerows(ListKeys)
                            ItemID = order.TransactionArray.Transaction[0].Item.ItemID
                            TransactionID = Transaction_obj.TransactionID
                            Body = f'Thanks for shopping with us.\n\
                            Your {Quantity} x {Sku(SKU)[0]} Retail License Key:\n\
                            {KEY}\
                            1) Go to {Sku(SKU)[2]} - ms official\n\
                            2) Login with your email and enter the code\n\
                            3) Download and Install {Sku(SKU)[1]}\n\
                            4) Active product via {Sku(SKU)[3]}!\n\
                            If you can\'t do it,please don\'t make a ebay case, just contact me! i will full support to you!\n\
                            Please do not open any dispute or issue, if you encounter any problems just contact us and we will solve all the problems!\n\
                            Thank you!'
                            ImportMessage = {'ItemID': ItemID,  # Item ID that buyer purchase
                                               'MemberMessage': {
                                                   'Body': Body,
                                                   'EmailCopyToSender': 1,
                                                   'QuestionType': 'General',
                                                   'RecipientID': UserID
                                               }
                                               }
                            api.execute('AddMemberMessageAAQToPartner', ImportMessage)
                            #add key to User Note (SetUserNotes):
                            api.execute('SetUserNotes', {'Action': 'AddOrUpdate','ItemID': ItemID,'NoteText': f'{KEY}','TransactionID': TransactionID})
                            break
if __name__ == "__main__":
    ScanFolder = os.scandir()
    for file in ScanFolder:
        if file.is_file() and file.name.lower().endswith('.yaml'):
            ebay_config = file.name
            eBay(ebay_config)