import wave
import sys
from math import ceil
from struct import pack


filenames = sys.argv[1:]
print("Loading files: ",filenames)




#Open disk

print("wmic diskdrive list brief")
print("Did you check that \\\\.\\PhysicalDrive2 is the correct drive???? THIS CAN KILL YOUR LAPTOP!")
a=input()
if "yes" not in a:
    1/0

sd = open("\\\\.\\PhysicalDrive2", mode="rb")


sd.seek(0)
original = sd.read(512)
sd.close()

if original[0:15] == b"Brandon'sFS 1.0":
    print("correct card found")
else:
    print("card may not be formatted correctly...double check its the right one!")
    1/0

sd = open("\\\\.\\PhysicalDrive2", mode="rb+")

def sd_write_bytes(b):
    global sector_count, sd
    #sd.seek(sector_count*512)
    #blist = [b[n:n+512] for n in range(0,int(ceil(len(b)/512)),512 )]
    #for sect in blist:
    x = (b+b'\x00'*512)[:512]
    sd.write(x)
    sector_count += 1

waves_data=list()
sector_count = 2

for name in filenames:
    w = wave.open(name, "r")
    
    waves_data.append( (name, sector_count, w.getnframes()) )
    print("\n\nFile:         ",name)
    print("Sample width: ",w.getsampwidth())
    print("Sample rate:  ", w.getframerate())
    print("Num samples:  ", w.getnframes())
    
    sd.seek(sector_count*512)
    for z in range(int(ceil(w.getnframes()/512))):
        sd_write_bytes(w.readframes(512))

    w.close()

print(sector_count)

print()
sect0 = b"Brandon'sFS 1.0\x00"
for w in waves_data:
    name = w[0]
    start_sector = w[1]
    samples = w[2]
    print(name,": start_sector=",start_sector,", samples=",samples)
    sect0 += pack('>I', start_sector*512)
    sect0 += pack('>I', samples)

sect0 = (sect0+b'\x00'*512)[:512]
sd.seek(0)
sd.write(sect0)
