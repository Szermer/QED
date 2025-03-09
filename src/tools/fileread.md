# FileReadTool (View): Content Examination

FileReadTool (named "View" in the interface) reads files from the filesystem with support for both text and images, providing Claude with direct access to file contents.

## Complete Prompt

```typescript
// Tool Prompt: View
const MAX_LINES_TO_READ = 2000
const MAX_LINE_LENGTH = 2000

export const PROMPT = `Reads a file from the local filesystem. The file_path parameter must be an absolute path, not a relative path. By default, it reads up to ${MAX_LINES_TO_READ} lines starting from the beginning of the file. You can optionally specify a line offset and limit (especially handy for long files), but it's recommended to read the whole file by not providing these parameters. Any lines longer than ${MAX_LINE_LENGTH} characters will be truncated. For image files, the tool will display the image for you. For Jupyter notebooks (.ipynb files), use the ${NotebookReadTool.name} instead.`
```

> **Tool Prompt: View**
>
> Reads a file from the local filesystem. The file_path parameter must be an absolute path, not a relative path. By default, it reads up to 2000 lines starting from the beginning of the file. You can optionally specify a line offset and limit (especially handy for long files), but it's recommended to read the whole file by not providing these parameters. Any lines longer than 2000 characters will be truncated. For image files, the tool will display the image for you. For Jupyter notebooks (.ipynb files), use the ReadNotebook instead.

## Implementation Details

FileReadTool has sophisticated handling for different file types with several critical components:

1. **The FileReadTool React component** (`FileReadTool.tsx`)
   - Input validation through a Zod schema
   - Dynamic handling for different file types
   - Size and access limitation enforcement

2. **File reading mechanisms**
   - Special handling for text vs. image files
   - Support for pagination through offset/limit parameters
   - Size restrictions and optimization

Let's examine the key implementation sections:

```typescript
// File type validation and handling
async validateInput({ file_path, offset, limit }) {
  const fullFilePath = normalizeFilePath(file_path)

  if (!existsSync(fullFilePath)) {
    // Try to find a similar file with a different extension
    const similarFilename = findSimilarFile(fullFilePath)
    let message = 'File does not exist.'

    // If we found a similar file, suggest it to the assistant
    if (similarFilename) {
      message += ` Did you mean ${similarFilename}?`
    }

    return {
      result: false,
      message,
    }
  }

  // Get file stats to check size
  const stats = statSync(fullFilePath)
  const fileSize = stats.size
  const ext = path.extname(fullFilePath).toLowerCase()

  // Skip size check for image files - they have their own size limits
  if (!IMAGE_EXTENSIONS.has(ext)) {
    // If file is too large and no offset/limit provided
    if (fileSize > MAX_OUTPUT_SIZE && !offset && !limit) {
      return {
        result: false,
        message: formatFileSizeError(fileSize),
        meta: { fileSize },
      }
    }
  }

  return { result: true }
}
```

The image handling logic is particularly sophisticated:

```typescript
// Image processing with smart resizing and compression
async function readImage(
  filePath: string,
  ext: string,
): Promise<{
  type: 'image'
  file: { base64: string; type: ImageBlockParam.Source['media_type'] }
}> {
  try {
    const stats = statSync(filePath)
    const sharp = (await import('sharp')).default
    const image = sharp(readFileSync(filePath))
    const metadata = await image.metadata()

    // Calculate dimensions while maintaining aspect ratio
    let width = metadata.width || 0
    let height = metadata.height || 0

    // Check if the original file is small enough
    if (
      stats.size <= MAX_IMAGE_SIZE &&
      width <= MAX_WIDTH &&
      height <= MAX_HEIGHT
    ) {
      return createImageResponse(readFileSync(filePath), ext)
    }

    // Resize proportionally if needed
    if (width > MAX_WIDTH) {
      height = Math.round((height * MAX_WIDTH) / width)
      width = MAX_WIDTH
    }

    if (height > MAX_HEIGHT) {
      width = Math.round((width * MAX_HEIGHT) / height)
      height = MAX_HEIGHT
    }

    // Resize image and convert to buffer
    const resizedImageBuffer = await image
      .resize(width, height, {
        fit: 'inside',
        withoutEnlargement: true,
      })
      .toBuffer()

    // If still too large after resize, compress quality
    if (resizedImageBuffer.length > MAX_IMAGE_SIZE) {
      const compressedBuffer = await image.jpeg({ quality: 80 }).toBuffer()
      return createImageResponse(compressedBuffer, 'jpeg')
    }

    return createImageResponse(resizedImageBuffer, ext)
  } catch (e) {
    // Fallback to original image if processing fails
    return createImageResponse(readFileSync(filePath), ext)
  }
}
```

## Key Components

FileReadTool has several critical features:

1. **Text file handling**
   - Automatic encoding detection (UTF-8, UTF-16LE, ASCII)
   - Line limit enforcement (2000 lines default)
   - Character length truncation (2000 chars per line)
   - Size limiting (0.25MB max for text files)
   - Line numbering for better context

2. **Image handling**
   - Support for common formats (PNG, JPG, GIF, BMP, WEBP)
   - Dynamic resizing to max dimensions (2000x2000px)
   - Aspect ratio preservation during resizing
   - Quality reduction for oversized images
   - Format conversion to JPEG for large files
   - Base64 encoding for Claude's image display capability

3. **User experience enhancements**
   - Similar file suggestion when file not found
   - Helpful error messages with size information
   - Pagination support for large files
   - Line counting for context

## Architecture

The FileReadTool architecture follows a logical flow:

```
FileReadTool.tsx (React component)
  ↓
validateInput() → Input validation and size checking
  ↓
call() → Dispatch to specific handler based on file type
  ↓
readTextContent() or readImage() → Type-specific processing
  ↓
renderResultForAssistant() → Format for Claude's consumption
```

The tool intelligently handles different file types through extension detection and applies appropriate processing strategies.

## Permission Handling

FileReadTool uses the standard read permission model:

```typescript
needsPermissions({ file_path }) {
  return !hasReadPermission(file_path || getCwd())
}
```

This ensures Claude has read access to the specified file before displaying its contents. The permission is requested only once per directory, making subsequent file reads more efficient.

## Usage Examples

Common usage patterns:

1. **Reading an entire file**
   ```
   View(file_path: "/path/to/file.txt")
   ```

2. **Reading specific portions of large files**
   ```
   View(file_path: "/path/to/large.log", offset: 1000, limit: 100)
   ```

3. **Viewing images**
   ```
   View(file_path: "/path/to/image.png")
   ```

FileReadTool is one of Claude's most frequently used tools, as examining file contents is fundamental to understanding code structure, debugging, and implementing changes. It's designed to be user-friendly while incorporating sophisticated handling for different file types and sizes.

