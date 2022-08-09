# CODE TO ZIP THE CEQ STATA COMMANDS TO SUBMIT TO SSC
#  Sean Higgins
#  Last updated 31mar2017

# PACKAGES
import zipfile
import zlib
import os # for shell commands like change directory
import shutil # for shell commands like copy
import datetime

# DATE FOR STAMP
now = datetime.datetime.now()

# DIRECTORIES
os.chdir('/Users/beenishamjad/Desktop/CEQStataPackage')

# LISTS
ados = [
	'ceq',
	'ceqdes',
	'ceqpop',
	'ceqextpop',
	'ceqlorenz',
	'ceqiop',
	'ceqfi',
	'ceqstatsig',
	'ceqdom',
	'ceqef',
	'ceqconc',
	'ceqfiscal',
	'ceqextend',
	'ceqmarg',
	'ceqefext',
	'ceqcov',
	'ceqextsig',
	'ceqdomext',
	'ceqcoverage',
	'ceqtarget',
	'ceqeduc',
	'ceqinfra',
	'ceqhhchar',
	'ceqindchar',
	'ceqgraph',
	'ceqgraph_fi',
	'ceqgraph_cdf',
	'ceqgraph_progressivity',
	'ceqgraph_conc',
	'ceqassump',
	'oppincidence',
	'incomecdf',
	'ceqppp',
	'covconc'
]
ados_only = [
	'ceqdientropy',
	'ceqdifgt',
	'ceqdigini',
	'ceqdinineq',
	'ceq_parse_using'
]
ados_sthlps = []
for ado in ados:
	ados_sthlps.append(ado + '.ado')
	ados_sthlps.append(ado + '.sthlp')
for ado in ados_only:
	ados_sthlps.append(ado + '.ado')

myzip = 'ceq.zip'

# ZIPIFY 
compression = zipfile.ZIP_DEFLATED
zf = zipfile.ZipFile(myzip, mode='w')
	# note: mode='w' to write a new file; mode='a' to append to an existing file
for file in ados_sthlps:
	print('adding %s to %s' % (file, myzip))
	zf.write(file,compress_type=compression)
zf.close()

# CREATE THE .pkg FILE:
pkg = open('ceq.pkg', 'w')

pkg.write('v 3\n')
pkg.write("d 'ceq': Estimates fiscal incidence and exports results directly to the CEQ Master Workbook\n")
pkg.write('d \n')
pkg.write('d Distribution date: ' + now.strftime("%Y%m%d") + '\n')
pkg.write('d \n')

for file_ in ados_sthlps:
	pkg.write('f ' + file_ + '\n')

pkg.close()

