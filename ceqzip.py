# CODE TO ZIP THE CEQ STATA COMMANDS TO SUBMIT TO SSC
#  Sean Higgins
#  Last updated 31mar2017

# PACKAGES
import zipfile
import zlib
import os # for shell commands like change directory
import shutil # for shell commands like copy

# DIRECTORIES
os.chdir('C:/Dropbox/CEQGates/ado_files')
copyto = 'C:/Dropbox/CEQGates/Handbook/3. CEQ Ado files working folder/ceq'
	# copyto contains the shared folder where the .zip will be copied

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
	'ceqppp'
]
ados_only = [
	'ceqdientropy',
	'ceqdifgt',
	'ceqdigini',
	'ceqdinineq'
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
	print 'adding %s to %s' % (file, myzip)
	zf.write(file,compress_type=compression)
zf.close()

# COPY TO CEQ METHODOLOGY SHARED DROPBOX FOLDER
shutil.copy(myzip,copyto)
