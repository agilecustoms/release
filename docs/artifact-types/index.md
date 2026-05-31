# Use cases

- [No artifacts, just git tags](./git.md)
- [Publish in AWS S3](./aws-s3.md)
- [Publish in AWS ECR](./aws-ecr.md)

## Language-specific Software packages

| Language   | Tool   | Publish in                                              |
|------------|--------|---------------------------------------------------------|
| java       | maven  | ✅ [AWS CodeArtifact](./aws-codeartifact-maven.md)       |
| javascript | npm    | ✅ [npmjs.com](./npmjs.md)                               |
| python     | poetry | ⚪ just update version in `pyproject.toml`               |
| python     | uv     | ⚪ just update version in `pyproject.toml` and `uv.lock` |
