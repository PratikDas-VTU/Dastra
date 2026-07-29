from PIL import Image, ImageEnhance, ImageFilter

input_path = 'assets/images/d_only.png'
img = Image.open(input_path).convert('RGBA')

# The img is cropped to the exact bounds of the D.
# We want to place it in the center of a 256x256 square with a slight margin.
canvas_size = 256
margin = 24
target_size = canvas_size - 2 * margin

# Calculate scaling factor to fit within target_size while maintaining aspect ratio
w, h = img.size
scale = min(target_size / w, target_size / h)
new_w = int(w * scale)
new_h = int(h * scale)

img = img.resize((new_w, new_h), Image.Resampling.LANCZOS)

base = Image.new('RGBA', (canvas_size, canvas_size), (0, 0, 0, 0))
# Center it
offset_x = (canvas_size - new_w) // 2
offset_y = (canvas_size - new_h) // 2
base.paste(img, (offset_x, offset_y), img)

sizes = [256, 128, 64, 48, 32, 24, 16]
images = []

for size in sizes:
    r = base.resize((size, size), Image.Resampling.LANCZOS)
    if size <= 48:
        # Boost contrast and apply unsharp mask for small sizes to make it pop
        r = ImageEnhance.Contrast(r).enhance(1.4)
        r = r.filter(ImageFilter.UnsharpMask(radius=2.0, percent=150, threshold=3))
    images.append(r)

# Overwrite the Windows runner icon
output_path = 'windows/runner/resources/app_icon.ico'
images[0].save(output_path, format='ICO', append_images=images[1:])
print("New stylized taskbar icon built successfully.")
