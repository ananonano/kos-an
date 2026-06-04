# Pake node 18 yang enteng
FROM node:18-alpine

# Set working directory di dalam container
WORKDIR /app

# Copy file dependency biar cepet di-install
COPY package*.json ./

# Install semua dependencies
RUN npm install

# Copy sisa kodingan lu ke dalam container
COPY . .

# Backend lu biasanya jalan di port 5000 kan?
EXPOSE 5000

# Perintah buat jalanin backend
CMD ["npm", "start"]