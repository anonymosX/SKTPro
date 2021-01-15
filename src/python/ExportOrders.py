#!/bin/python3
from woocommerce import API
import csv
from ebaysdk.trading import Connection as Trading
import os
from datetime import datetime, timedelta
from pytz import timezone
import sys
from tqdm import tqdm
import time
import requests
def Shopify(ID,API_KEY,PASSWORD,STORE,VERSION):
    order_obj = requests.get("https://%s:%s@%s.myshopify.com/admin/api/%s/orders.json?status=open&limit=250&fulfillment_status=unfulfilled"%(API_KEY,PASSWORD,STORE,VERSION))
    for attribute in order_obj.json()['orders']:
        for variant in attribute['line_items']:
            if attribute['shipping_address']['phone'] == None:
                PHONE = ''
            else:
                PHONE = attribute['shipping_address']['phone']
            if attribute['shipping_address']['address2'] == '':
                ADDRESS = attribute['shipping_address']['address1']
            else:
                ADDRESS = f"{attribute['shipping_address']['address1']} {attribute['shipping_address']['address2']}"
            ORDER_ID = attribute['id']
            transaction_obj = requests.get("https://%s:%s@%s.myshopify.com/admin/api/%s/orders/%s/transactions.json"%(API_KEY,PASSWORD,STORE,VERSION,ORDER_ID))
            INVOICE = f"{ID}-{attribute['id']}"
            for transaction in transaction_obj.json()['transactions']:
                TRANSACTION = transaction['authorization']

                ORDER.append(['E4',TRANSACTION,INVOICE, f"{attribute['shipping_address']['first_name']} {attribute['shipping_address']['last_name']}",PHONE,ADDRESS, attribute['shipping_address']['city'], attribute['shipping_address']['province'],attribute['shipping_address']['zip'], variant['sku'], variant['quantity'], 'Build Stock Later'])
    return ORDER
def Woocommerce(URL,INVOICE_ID,CONSUMER_KEY,CONSUMER_SECRET,VERSION):
    wcapi = API(
        url = URL,
        consumer_key = CONSUMER_KEY,
        consumer_secret = CONSUMER_SECRET,
        version = VERSION
    )
    for attribute in wcapi.get("orders").json():
        if attribute['status'] == 'processing':
            for i in wcapi.get("payment_gateways").json():
                if i['id'] == 'paypal':
                    PAYPAL = i['settings']['invoice_prefix']['value']
            INVOICE = f"{INVOICE_ID}-{attribute['number']}"
            ShippingInfo = attribute['shipping']
            NAME = f"{ShippingInfo['first_name']} {ShippingInfo['last_name']}"
            if ShippingInfo['address_2'] != None:
                ADDRESS = f"{ShippingInfo['address_1']}  {ShippingInfo['address_2']}"
            else:
                ADDRESS = f"{ShippingInfo['address_1']}"
            CITY = ShippingInfo['city']
            STATE = ShippingInfo['state']
            ZIPCODE = ShippingInfo['postcode']
            TRANSACTION = attribute['transaction_id']
            PHONE = attribute['billing']['phone']
            for variant in attribute['line_items']:
                SKU = variant['sku']
                QUANTITY = variant['quantity']
                ORDERS.append([PAYPAL, TRANSACTION, INVOICE, NAME, PHONE, ADDRESS, CITY, STATE, ZIPCODE, SKU, QUANTITY, 'Build Stock Later'])
    return ORDERS
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
def eBay(config):
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
                ShippingInfo = order.ShippingAddress
                Name = ShippingInfo.Name
                OrderID = order.OrderID
                Phone = ShippingInfo.Phone
                Add1 = ShippingInfo.Street1
                Add2 = ShippingInfo.Street2
                #kiem tra thu variant co don ko:
                try:
                    VariantSKU = Transaction_obj.Variation.SKU
                except AttributeError:
                    VariantSKU = ''
                if Add2 == None:
                    Add2 = ''
                    Add = Add1
                else:
                    Add = f'{Add1} {Add2}'
                States = ShippingInfo.StateOrProvince
                City = ShippingInfo.CityName
                PostalCode = ShippingInfo.PostalCode
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
                try:
                    REALSKU = SKU.split('|')[1]
                except IndexError:
                    REALSKU = None
                #DROPSHIP
                print(f'{SKU} {INVOICE} {order.CreatedTime.strftime("%Y-%m-%d")}')
                if FILTER == 'DS':
                    DROPSHIP.append(['','',INVOICE, Name, Phone, Add, City, States, PostalCode, REALSKU, Quantity])
                #WAREHOUSE FILTER
                elif FILTER == 'PS':
                    WAREHOUSE.append(['','',INVOICE, Name, Phone, Add, City, States, PostalCode,REALSKU, Quantity,'Build Stock Later'])
                #DIGITAL KEY FILTER
                elif FILTER == 'DI' and Sku(SKU)[0] != None:
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
                            print(f'Processing key: {Account}, User: {UserID}')
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
                            #update key
                            break
                        #if digital is out of stock! then marked notes to csv file
                        elif Stock(SKU) == 0:
                            DIGITAL.append(['','',INVOICE, Name, Phone, Add, City, States, PostalCode,REALSKU, Quantity,'Unsent message'])
if __name__ == "__main__":
    DROPSHIP = []
    WAREHOUSE = []
    DIGITAL = []
    ORDER = []
    ORDERS = []
    for i in tqdm(range(100),
                  desc="Loading...",
                  ascii=False, ncols=90):
        time.sleep(0.01)
    #Woocommerce Export:
    with open('woocommerce.csv','r') as identify:
        woocommerce = [row for row in csv.DictReader(identify)]
    for store in woocommerce:
        URL = f"https://{store['URL']}"
        INVOICE = store['INVOICE']
        CONSUMER_KEY = store['CONSUMER_KEY']
        CONSUMER_SECRET = store['CONSUMER_SECRET']
        VERSION = store['VERSION']
        WOO_ORDERS = Woocommerce(URL,INVOICE,CONSUMER_KEY,CONSUMER_SECRET,VERSION)
    #Shopify Export:
    with open('shopify.csv', 'r') as identify:
        shopify = [row for row in csv.DictReader(identify)]
    for store in shopify:
        shopify_id = store['ID']
        shopify_key = store['KEY']
        shopify_pass = store['PASSWORD']
        shopify_url = store['STORE_ID']
        shopify_version = store['VERSION']
        SHOPIFY_ORDERS = Shopify(shopify_id,shopify_key,shopify_pass,shopify_url,shopify_version)
    ScanFolder = os.scandir()
    for file in ScanFolder:
        if file.is_file() and file.name.lower().endswith('.yaml'):
            ebay_config = file.name
            eBay(ebay_config)
    HEADER = ['PAYPAL', 'TRANSACTION ID', 'INVOICE', 'NAME', 'PHONE', 'ADDRESS', 'CITY', 'STATES', 'ZIPCODE', 'SKU',
                  'QUANTITY', 'STATUS']
    with open('/root/Orders.csv', 'w', newline='') as file:
        order = csv.writer(file)
        order.writerow(HEADER)
        order.writerow(['1/ Kho Hau:'])
        for i in range(0, sum(1 for a in WOO_ORDERS)):
            order.writerow(WOO_ORDERS[i])
        for i in range(0, sum(1 for a in SHOPIFY_ORDERS)):
            order.writerow(SHOPIFY_ORDERS[i])
        if sum(1 for a in WAREHOUSE) > 0:
            for i in range(0, sum(1 for a in WAREHOUSE)):
                order.writerow(WAREHOUSE[i])
        if sum(1 for a in DROPSHIP) > 0:
            order.writerow(['2/ Check out:'])
            for i in range(0, sum(1 for a in DROPSHIP)):
                order.writerow(DROPSHIP[i])
        if sum(1 for a in DIGITAL) > 0:
            order.writerow(['3/ Key Unsent:'])
            for i in range(0, sum(1 for a in DIGITAL)):
                order.writerow(DIGITAL[i])