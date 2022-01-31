FROM node:latest as build

# Add the source code to app
COPY ./Source/frontend/. /app/
WORKDIR /app

# Install all the dependencies
RUN npm install

# Generate the build of the application
RUN npm run build



FROM ubuntu
RUN apt-get update 
RUN apt-get install -y nginx
RUN apt-get install -y python
RUN apt-get install python3-pip
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

COPY /Source/backend/* /app/
COPY requirements.txt .
RUN python -m pip install -r requirements.txt

WORKDIR /app/
CMD exec python manage.py collectstatic

# Copy the build output to replace the default nginx contents.
COPY --from=build /app/build/. /usr/share/nginx/html/
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d

ENTRYPOINT ["/tini", "--", "./start.sh"]
