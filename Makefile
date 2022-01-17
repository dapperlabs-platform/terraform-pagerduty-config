all: docs

docs:
	terraform-docs markdown table --header-from header.md . > README.md