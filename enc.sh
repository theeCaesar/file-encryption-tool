#!/bin/bash

# Path to the Python face-password script
FACE_PASSWORD_SCRIPT="face_password.py"

generate_face_password() {
    echo "Enter a face image path:"
    read  FACE_IMAGE
    echo "Generating password from your face..."
    PASSWORD=$(python "$FACE_PASSWORD_SCRIPT" "$FACE_IMAGE")
    if [ $? -ne 0 ]; then
        echo "Failed to generate password from face."
        exit 1
    fi
    echo "Password generated successfully!"
}

get_manual_password() {
    echo "Enter a password:"
    read -s PASSWORD
    if [ -z "$PASSWORD" ]; then
        echo "Password cannot be empty!"
        exit 1
    fi
}

encrypt_file_openssl() {
    echo "Enter the file to encrypt:"
    read file_to_encrypt
    if [ ! "$file_to_encrypt" ]; then
        echo "File does not exist!"
        exit 1
    fi

    echo "Choose the password method:"
    echo "1. Use Face as Password"
    echo "2. Enter Password Manually"
    read password_choice

    case $password_choice in
        1)
            generate_face_password
            ;;
        2)
            get_manual_password
            ;;
        *)
            echo "Invalid choice!"
            exit 1
            ;;
    esac

    openssl enc -aes-256-cbc -salt -in "$file_to_encrypt" -out "${file_to_encrypt}.enc" -pass pass:"$PASSWORD"
    if [ $? -eq 0 ]; then
        echo "File encrypted successfully using OpenSSL!"
    else
        echo "OpenSSL encryption failed!"
    fi
}

decrypt_file_openssl() {
    echo "Enter the file to decrypt:"
    read file_to_decrypt
    if [ ! -f "$file_to_decrypt" ]; then
        echo "File does not exist!"
        exit 1
    fi

    echo "Choose the password method:"
    echo "1. Use Face as Password"
    echo "2. Enter Password Manually"
    read password_choice

    case $password_choice in
        1)
            generate_face_password
            ;;
        2)
            get_manual_password
            ;;
        *)
            echo "Invalid choice!"
            exit 1
            ;;
    esac

    openssl enc -aes-256-cbc -d -in "$file_to_decrypt" -out "${file_to_decrypt%.enc}" -pass pass:"$PASSWORD"
    if [ $? -eq 0 ]; then
        echo "File decrypted successfully using OpenSSL!"
    else
        echo "OpenSSL decryption failed! Ensure the correct password or face is used."
    fi
}

encrypt_file_gpg() {
    echo "Enter the file to encrypt:"
    read file_to_encrypt
    if [ ! -f "$file_to_encrypt" ]; then
        echo "File does not exist!"
        exit 1
    fi

    echo "Choose the password method:"
    echo "1. Use Face as Password"
    echo "2. Enter Password Manually"
    read password_choice

    case $password_choice in
        1)
            generate_face_password
            ;;
        2)
            get_manual_password
            ;;
        *)
            echo "Invalid choice!"
            exit 1
            ;;
    esac

    echo "$PASSWORD" | gpg --batch --yes --passphrase-fd 0 --symmetric "$file_to_encrypt"
    if [ $? -eq 0 ]; then
        echo "File encrypted successfully using GPG!"
    else
        echo "GPG encryption failed!"
    fi
}

decrypt_file_gpg() {
    echo "Enter the file to decrypt:"
    read file_to_decrypt
    if [ ! -f "$file_to_decrypt" ]; then
        echo "File does not exist!"
        exit 1
    fi

    echo "Choose the password method:"
    echo "1. Use Face as Password"
    echo "2. Enter Password Manually"
    read password_choice

    case $password_choice in
        1)
            generate_face_password
            ;;
        2)
            get_manual_password
            ;;
        *)
            echo "Invalid choice!"
            exit 1
            ;;
    esac

    echo "$PASSWORD" | gpg --batch --yes --passphrase-fd 0 --decrypt "$file_to_decrypt" > "${file_to_decrypt%.gpg}"
    if [ $? -eq 0 ]; then
        echo "File decrypted successfully using GPG!"
    else
        echo "GPG decryption failed! Ensure the correct password or face is used."
    fi
}

encrypt_directory_openssl() {
    echo "Enter the directory to encrypt:"
    read dir_to_encrypt
    if [ ! -d "$dir_to_encrypt" ]; then
        echo "Directory does not exist!"
        exit 1
    fi

    echo "Choose the password method:"
    echo "1. Use Face as Password"
    echo "2. Enter Password Manually"
    read password_choice

    case $password_choice in
        1)
            generate_face_password
            ;;
        2)
            get_manual_password
            ;;
        *)
            echo "Invalid choice!"
            exit 1
            ;;
    esac

    find "$dir_to_encrypt" -type f | while read file; do
        openssl enc -aes-256-cbc -salt -in "$file" -out "${file}.enc" -pass pass:"$PASSWORD"
        if [ $? -eq 0 ]; then
            echo "Encrypted $file using OpenSSL!"
        else
            echo "Failed to encrypt $file!"
        fi
    done
}

decrypt_directory_openssl() {
    echo "Enter the directory to decrypt:"
    read dir_to_decrypt
    if [ ! -d "$dir_to_decrypt" ]; then
        echo "Directory does not exist!"
        exit 1
    fi

    echo "Choose the password method:"
    echo "1. Use Face as Password"
    echo "2. Enter Password Manually"
    read password_choice

    case $password_choice in
        1)
            generate_face_password
            ;;
        2)
            get_manual_password
            ;;
        *)
            echo "Invalid choice!"
            exit 1
            ;;
    esac

    find "$dir_to_decrypt" -type f -name "*.enc" | while read file; do
        openssl enc -aes-256-cbc -d -in "$file" -out "${file%.enc}" -pass pass:"$PASSWORD"
        if [ $? -eq 0 ]; then
            echo "Decrypted $file using OpenSSL!"
        else
            echo "Failed to decrypt $file!"
        fi
    done
}

encrypt_directory_gpg() {
    echo "Enter the directory to encrypt:"
    read dir_to_encrypt
    if [ ! -d "$dir_to_encrypt" ]; then
        echo "Directory does not exist!"
        exit 1
    fi

    echo "Choose the password method:"
    echo "1. Use Face as Password"
    echo "2. Enter Password Manually"
    read password_choice

    case $password_choice in
        1)
            generate_face_password
            ;;
        2)
            get_manual_password
            ;;
        *)
            echo "Invalid choice!"
            exit 1
            ;;
    esac

    find "$dir_to_encrypt" -type f | while read file; do
        echo "$PASSWORD" | gpg --batch --yes --passphrase-fd 0 --symmetric "$file"
        if [ $? -eq 0 ]; then
            echo "Encrypted $file using GPG!"
        else
            echo "Failed to encrypt $file!"
        fi
    done
}

decrypt_directory_gpg() {
    echo "Enter the directory to decrypt:"
    read dir_to_decrypt
    if [ ! -d "$dir_to_decrypt" ]; then
        echo "Directory does not exist!"
        exit 1
    fi

    echo "Choose the password method:"
    echo "1. Use Face as Password"
    echo "2. Enter Password Manually"
    read password_choice

    case $password_choice in
        1)
            generate_face_password
            ;;
        2)
            get_manual_password
            ;;
        *)
            echo "Invalid choice!"
            exit 1
            ;;
    esac

    # Decrypt all files in the directory
    find "$dir_to_decrypt" -type f -name "*.gpg" | while read file; do
        echo "$PASSWORD" | gpg --batch --yes --passphrase-fd 0 --decrypt "$file" > "${file%.gpg}"
        if [ $? -eq 0 ]; then
            echo "Decrypted $file using GPG!"
        else
            echo "Failed to decrypt $file!"
        fi
    done
}

while true; do
    echo "Choose an action:"
    echo "1. Encrypt a file with OpenSSL"
    echo "2. Decrypt a file with OpenSSL"
    echo "3. Encrypt a file with GPG"
    echo "4. Decrypt a file with GPG"
    echo "5. Encrypt a directory with OpenSSL"
    echo "6. Decrypt a directory with OpenSSL"
    echo "7. Encrypt a directory with GPG"
    echo "8. Decrypt a directory with GPG"
    echo "9. Exit"
    read choice

    case $choice in
        1) encrypt_file_openssl ;;
        2) decrypt_file_openssl ;;
        3) encrypt_file_gpg ;;
        4) decrypt_file_gpg ;;
        5) encrypt_directory_openssl ;;
        6) decrypt_directory_openssl ;;
        7) encrypt_directory_gpg ;;
        8) decrypt_directory_gpg ;;
        9) exit ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
done
