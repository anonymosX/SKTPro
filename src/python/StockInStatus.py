import csv
from datetime import datetime
#email out of stock soon
#mo file sku.csv lay gia tri sku, roi doi chieu stock voi file key.csv
#LAY THONG TIN DUA THEO SKU
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
    return title, type, link, active
#KIEM TRA STOCK STATUS
def Stock(SKU):
    with open('key.csv', mode = 'r', newline = '') as KEYS:
        ListKeys = [raw for raw in csv.DictReader(KEYS)]
    TotalKeys = sum(1 for raw in ListKeys)
    Stock = 0
    for i in range(0, TotalKeys):
        if ListKeys[i]['SKU'] == SKU and ListKeys[i]['STATUS'] == '':
            Stock += 1
    return Stock
def StockStatus():
    with open('sku.csv', 'r', newline='') as file:
        ListKeys = [raw for raw in csv.DictReader(file)]
    print('1/ Stock status: ')
    for i in range(0, sum(1 for raw in ListKeys)):
        SKU = ListKeys[i]['SKU']
        if Stock(SKU) > 5:
            print(f'{i+1}) {Stock(SKU)} x {Sku(SKU)[0]} in stock')
            #print(i+1,"{0:<12}{1:^30}{2:>15}".format('<stock in>', Sku(SKU)[0],'stock: ' + str(Stock(SKU))))
        elif Stock(SKU) < 5 and Stock(SKU) > 0:
            print(f'{i+1}) <Out stock soon>:{Stock(SKU)} x {Sku(SKU)[0]} in stock!')
            #print(i+1,"{0:<12}{1:^30}{2:>14}".format('<order soon>',Sku(SKU)[0],'stock: ' + str(Stock(SKU))))
        elif Stock(SKU) == 0:
            print(f'{i+1}) <Buy Now>: {Sku(SKU)[0]} is out of stock')
            #print(i+1,"{0:<12}{1:^30}{2:>15}".format('<buy now>', Sku(SKU)[0],'stock: ' + str(Stock(SKU))))
if __name__ == "__main__":
    time = datetime.now().strftime("%d-%m-%Y")
    print(f'Order date: {time}')
    StockStatus()
    print('2/ Orders file:')