from PIL import Image
import os, glob, sys

src = r'C:\Users\Brown\Desktop\OpsRoom_Dev\OpsRoom\gui\textures'
pngs = glob.glob(os.path.join(src, '*.png'))

if not pngs:
    print('No PNG files found in textures folder!')
    sys.exit(0)

for p in pngs:
    img = Image.open(p)
    old = img.size
    if old == (256, 256):
        print(f'  OK: {os.path.basename(p)} (already 256x256)')
        continue
    img = img.resize((256, 256), Image.LANCZOS)
    img.save(p, 'PNG')
    print(f'  Resized: {os.path.basename(p)} ({old[0]}x{old[1]} -> 256x256)')

print(f'\nDone! Processed {len(pngs)} files.')
print('Next: Convert to .paa at https://paa.gruppe-adler.de/')
