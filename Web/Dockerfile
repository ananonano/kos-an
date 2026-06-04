# Pake node 18 yang enteng
FROM node:18-alpine

# Set working directory di dalam container
WORKDIR /app

# Copy file dependency
COPY package*.json ./

# Install semua dependencies
RUN npm install

# Copy sisa kodingan lu ke dalam container
COPY . .

# Build aplikasi Next.js lu biar jadi static files
RUN npm run build

# Next.js biasanya jalan di port 3000
EXPOSE 3000

# Perintah buat jalanin web
CMD ["npm", "start"]