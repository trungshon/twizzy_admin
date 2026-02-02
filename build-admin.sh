#!/bin/bash
# Build and deploy Flutter Admin to Twizzy-BE

echo "Building Flutter Web..."
MSYS_NO_PATHCONV=1 flutter build web --release --base-href="/admin-web/"

if [ $? -eq 0 ]; then
    echo "Copying to Twizzy-BE/admin..."
    cp -r build/web/* /d/workspace/Twizzy/Twizzy-BE/admin/
    echo "Done! Refresh browser at http://localhost:3000/admin-web/"
else
    echo "Build failed!"
fi
