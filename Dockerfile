FROM python:3.12-alpine
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
ARG VERSION=dev
RUN echo "$VERSION" > /app/VERSION
ENV APP_PORT=5001
ENV PYTHONDONTWRITEBYTECODE=1
ENV MARKER=sitelab
EXPOSE 5001
CMD ["python", "app.py"]
