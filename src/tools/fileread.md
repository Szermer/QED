# View: Reading Files

View reads files from the filesystem with support for both text and images, providing direct access to file contents.

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

## How It Works

View handles different file types with specialized processing:

1. **Core Components**
   - Input validation using Zod schema
   - Type-specific handlers for different file formats
   - Size and access limits for safe operation

2. **Reading Mechanisms**
   - Different handlers for text and image files
   - Pagination support with offset/limit parameters
   - File size management and optimization

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

## Key Features

View offers specialized handling for different file types:

1. **Text Processing**
   - Encoding detection
   - 2000-line default output limit
   - Line truncation for excessive length
   - Size cap for text files
   - Line numbering

2. **Image Processing**
   - Support for common image formats
   - Dynamic resizing for large images
   - Aspect ratio preservation
   - Quality reduction for oversized files
   - Format conversion when needed

3. **User Experience**
   - Similar file suggestions
   - Contextual error messages
   - Pagination for large files
   - Line count display

## Architecture

The View tool architecture follows a logical flow:

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

The tool detects file types by extension and applies the appropriate processing strategy for each type.

## Permissions

View uses a simple read permission model:

```typescript
needsPermissions({ file_path }) {
  return !hasReadPermission(file_path || getCwd())
}
```

This verifies read access before displaying file contents. Permissions are requested per directory rather than per file, making multiple reads from the same location more efficient.

## Usage Examples

Typical ways to use View:

1. **Reading a complete file**
   ```
   View(file_path: "/path/to/file.txt")
   ```

2. **Reading part of a large file**
   ```
   View(file_path: "/path/to/large.log", offset: 1000, limit: 100)
   ```

3. **Viewing images**
   ```
   View(file_path: "/path/to/image.png")
   ```

View provides core functionality for reading code and content, with type-specific processing for both text and images.

