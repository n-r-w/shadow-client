# based on https://github.com/MagomedovTimur/WireGuard-AllowedIPs-Calculator

import sys
from netaddr import iprange_to_cidrs
from ipaddress import IPv4Network
from ipaddress import IPv4Address	
from ipaddress import summarize_address_range

  
# Default network sorting algorithm takes into account the network mask.
# We need to sort network only by netowrk address
def mySorted(netArray):
	
	i = 0

	while i < len(netArray) - 1:
		a = (netArray[i].split('/'))[0]
		b = (netArray[i+1].split('/'))[0]

		# Breaking into the int(octets
		octetsA = a.split(".")
		octetsB = b.split(".")
		
		if int(octetsA[0]) > int(octetsB[0]):
			current = netArray[i]
			netArray[i] = netArray[i+1]
			netArray[i+1] = current
			i=-1
		elif int(octetsA[0]) < int(octetsB[0]):
			pass
		elif int(octetsA[1]) > int(octetsB[1]):
			current = netArray[i]
			netArray[i] = netArray[i+1]
			netArray[i+1] = current
			i=-1
		elif int(octetsA[1]) < int(octetsB[1]):
			pass
		elif int(octetsA[2]) > int(octetsB[2]):
			current = netArray[i]
			netArray[i] = netArray[i+1]
			netArray[i+1] = current
			i=-1
		elif int(octetsA[2]) < int(octetsB[2]):
			pass
		elif int(octetsA[3]) > int(octetsB[3]):
			current = netArray[i]
			netArray[i] = netArray[i+1]
			netArray[i+1] = current
			i=-1
		elif int(octetsA[3]) < int(octetsB[3]):
			pass
		i+=1		

	return netArray


def convertRangesToNets(netRange):
	
	result = []
	
	# Transforming each network range into a networks and write each of them to the result array
	for net in netRange:
		resultNetworks = iprange_to_cidrs(str(net[0]), str(net[1]))
		for resultNet in resultNetworks:
			result.append(IPv4Network(str(resultNet)))
	return result

def rangeSubstraction(allowedRange, disallowedRange):
	
	i = 0
	while i < len(allowedRange):

		for disallowedNet in disallowedRange:
			

			if (allowedRange[i][0] >= disallowedNet[0]) and (allowedRange[i][1] <= disallowedNet[1]):
				allowedRange.pop(i)
				i=0
				break
			if (allowedRange[i][0] < disallowedNet[0]) and (allowedRange[i][1] > disallowedNet[1]):
				allowedRange.append([allowedRange[i][0], (disallowedNet[0])-1])
				allowedRange.append([disallowedNet[1]+1, allowedRange[i][1]])
				allowedRange.pop(i)
				i=0
				break
			if (allowedRange[i][0] < disallowedNet[0]) and (allowedRange[i][1] >= disallowedNet[0]):
				allowedRange.append([allowedRange[i][0], disallowedNet[0]-1])
				allowedRange.pop(i)
				i=0
				break
			if (allowedRange[i][0] >= disallowedNet[0]) and (allowedRange[i][0] < disallowedNet[1]):
				allowedRange.append([disallowedNet[1]+1, allowedRange[i][1]])
				allowedRange.pop(i)
				i=0
				break
		i+=1
	return allowedRange

def summarizeNets(IPArr):
	# Insert all nets as a start and end addresses
	IPrange = []
	for currentNetwork in IPArr:
		IPrange.append([currentNetwork[0], currentNetwork[-1]])

	i = 0
	while i < len(IPrange)-1:
	
		if IPrange[i][1]+1 >= IPrange[i+1][0]:
			if IPrange[i][0] <= IPrange[i+1][0]:
				if IPrange[i][1] <= IPrange[i+1][1]:
					IPrange[i] = [IPrange[i][0], IPrange[i+1][1]]

				else:
					IPrange[i] = [IPrange[i][0], IPrange[i][1]]
			else:
				if IPrange[i][1] <= IPrange[i+1][1]:
					IPrange[i] = [IPrange[i+1][0], IPrange[i+1][1]]
				else:
					IPrange[i] = [IPrange[i+1][0], IPrange[i][1]]
			IPrange.pop(i+1)
			i=0
		i+=1

	return IPrange

def mainCalculator(allowedNet, disallowedNet):

	# Making IP inputs computer readable
	allowedNetTextArr = allowedNet.split(',')
	disallowedNetTextArr = disallowedNet.split(',')

	# Sorting IP arrays 
	allowedNetTextArr = mySorted(allowedNetTextArr)
	disallowedNetTextArr = mySorted(disallowedNetTextArr)

	# Pushing text ip addresses from arrays to ipaddress.ip_network array
	allowedNetArr = []
	disallowedNetArr = []

	for x in allowedNetTextArr:
		try:
			allowedNetArr.append(IPv4Network(x))
		except ValueError:
			print('Error: ' + x + ' has host bits set or incorrect format') 
			return
	for x in disallowedNetTextArr:
		try:
			disallowedNetArr.append(IPv4Network(x))
		except ValueError:
			print('Error: ' + x + ' has host bits set or incorrect format') 
			return

	# Summarizing networks if they overlap and get address ranges back
	allowedNetRanges = summarizeNets(allowedNetArr)
	disallowedNetRanges = summarizeNets(disallowedNetArr)

	# Subtracting blocked networks from allowed
	resultRanges = rangeSubstraction(allowedNetRanges,disallowedNetRanges)

	# Check if there any possible allowed networks
	if len(resultRanges) == 0:
		print('There are no allowed networks!')
		return

	# Removing 0.0.0.0 address in the start of resultRanges
	if resultRanges[0][0] == IPv4Address('0.0.0.0'):
		resultRanges[0][0] = IPv4Address('1.0.0.0')

	# Converting result ranges to result array with ip networks
	resultArray = convertRangesToNets(resultRanges)

	# Sorting netowrk result array 
	resultArray = sorted(resultArray)

	# Printing result
	result = ''

	if len(resultArray) == 0:
		return
	elif len(resultArray) == 1:
		result += str(resultArray[0])
	else:
		for i in range(0, len(resultArray)-1):
			result += str(resultArray[i]) + ','
		result = result[:-1]

	print(result)



	return

def main():

	# If there is no key or "-h" display help message and quit
	try:
		if (len(sys.argv) == 1) or sys.argv.index("-h") != None:
			help = """
	WireGuard allowedNets Calculator (https://github.com/MagomedovTimur/WireGuard-allowedNets-Calculator)

	Keys:
	-a <network/mask[,network2/mask][,network3/mask],...>: Allowed networks. Leave blank for 0.0.0.0/0
	-d <network/mask[,network2/mask][,network3/mask],...>: Disallowed networks. Optional if "-e" is used
	-r <Wiregurad allowedNets string>: Reverse wiregurad config string to allowed and disallowed networks
	-e: Preset for fast excluding local networks
	-h: print help message to console
	"""
			print(help)
			return
	except:
		pass


	disallowedNet = ''
	allowedNet = ''

	# Getting allowed networks from console. If there are no networks => 0.0.0.0/0
	try:
		allowedNet = sys.argv[sys.argv.index("-a") + 1]
	except ValueError:
		allowedNet = '0.0.0.0/0'


	# Getting disallowed netowrks from console. If there are no networks check if key "-e" is used. If no => print error
	try:
		disallowedNet = sys.argv[sys.argv.index("-d") + 1]
	except ValueError:
		try:

			excludeLocal = sys.argv[sys.argv.index("-e")]
			if disallowedNet != '':
				disallowedNet+=','
			disallowedNet+='10.0.0.0/8,127.0.0.0/8,169.254.0.0/16,172.16.0.0/12,192.168.0.0/16'

		except ValueError:
			print('Either a disallowed or preset networks are needed')
			return

	mainCalculator(allowedNet, disallowedNet)
	return


if __name__ == '__main__':
	main()
