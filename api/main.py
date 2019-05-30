from flask import Flask, request, Response, jsonify
import boto3
import base64 
import json as j
import os
app = Flask(__name__) 

with open('credentials.csv') as csv:
    ACCESS_KEY, SECRET_KEY = csv.read().strip().split('\n')[1].split(',')
REGION_NAME = 'us-east-1'

rekognition = boto3.client('rekognition',
                           aws_access_key_id=ACCESS_KEY,
                           aws_secret_access_key=SECRET_KEY,
                           region_name=REGION_NAME)



def carregar_imagem_usuario(login):
    imagens = {
        'arthur': 'imagens/arthur.jpeg',
        'thiago': 'imagens/thiago.jpeg',
        'edmario': 'imagens/edmario.jpeg',
        'geraldo': 'imagens/geraldo2.jpeg',
        'matheus': 'imagens/matheus.jpeg',
    }
    with open(imagens[login], 'rb') as imagem:
        return imagem.read()
    
@app.route("/")
def hello_world():
    return "Hello World"

def log(login, byten, byteo):
    try:
        if byteo:
            with open('imagens/original.jpeg', 'wb') as original:
                original.write(byteo)
        if byten:
            with open('imagens/nova.jpeg', 'wb') as nova:
                nova.write(byten)
        print('ULTIMO TENTATIVA DE LOGIN: {}'.format(login))
    except:
        print('erro')
@app.route("/detect", methods=['POST'])
def detect():
    json = request.json
    try:
        login = json['login']
        nova = base64.b64decode(json['nova'])
        original = carregar_imagem_usuario(login)
        log(login, nova, original)
        labels = rekognition.compare_faces(
            SimilarityThreshold=50,
            SourceImage={'Bytes': original},
            TargetImage={'Bytes': nova})
        
        # rekognition.compare_faces(Image={'Bytes': byte})
        if labels['FaceMatches']:
            acc = labels['FaceMatches'][0]['Similarity']
            print('Acuracia')
            print(acc)
            return jsonify({'result':  acc > 70})
        print('NO MATCH')
        return jsonify({'result': False})
    except Exception as e:
        print(e)
        return "fail"

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
