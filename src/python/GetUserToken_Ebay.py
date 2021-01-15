#GetSession ID:
from ebaysdk.trading import Connection as Trading
from ebaysdk.exception import ConnectionError


#CONFIRM YOUR DEVERLOP APPS:
APP_ID = 'QuocNgo-Order-PRD-45007f986-962faf68'
DEV_ID = 'cdb4fd62-351c-4aff-89c5-a48979a159ac'
CERT_ID = 'PRD-5007f986e853-1852-4c76-a7af-b2e2'
api  = Trading(appid = APP_ID, devid = DEV_ID, certid = CERT_ID,config_file = None)
def get_seasionID():
	try:		
		response = api.execute('GetSessionID',{'RuName':'Quoc_Ngo-QuocNgo-Order-P-dneyxv'})
		SeasionID = response.reply.SessionID
		return SeasionID
	except ConnectionError as e:
		return e.response.dict()
def get_FetchToken(SeasionID):
	try:
		response = api.execute('FetchToken',{'SessionID':SeasionID})
		Token = response.reply.eBayAuthToken
		return Token
	except ConnectionError as e:
		return e.response.dict()



if __name__ == '__main__':
	SeasionID = get_seasionID()
	print(f'Link authorization apps: \nhttps://signin.ebay.com/ws/eBayISAPI.dll?SignIn&runame=Quoc_Ngo-QuocNgo-Order-P-dneyxv&SessID={SeasionID}')
	option = input(f'Do you want get eBay token for this seasion ID: {SeasionID} (Yes or No): ')
	if option == 'Yes' or option == 'yes' or option == 'y':
		print(f'Your ebay token:\n{get_FetchToken(SeasionID)}')
	else:
		print('You are select NO')
