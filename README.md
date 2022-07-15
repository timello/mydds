# mydds
My Simple Decentralized Data Storage

myDDS has only 2 methods for simplicity:

1. PUT: receives a file in base64 format. The file is split into multiple parts,
encrypted and distribute across multiple nodes. The nodes are represented here as
AWS S3 buckets which can later be any object storage provider. The request
returns a hash which can be used to retrieve the file via GET method.

2. GET: receives the hash and retrieves the parts from the nodes and rebuilds
the original file.
