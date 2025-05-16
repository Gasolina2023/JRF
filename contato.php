<?php
header('Content-Type: application/json');

// 1. Configuração do banco de dados
$host = 'localhost';
$dbname = 'metalvidros';
$username = 'usuario';
$password = 'senha';

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // 2. Processar dados do formulário com sanitização e validação adequadas
    $nome = isset($_POST['name']) ? trim($_POST['name']) : '';
    $email = isset($_POST['email']) ? trim($_POST['email']) : '';
    $telefone = isset($_POST['phone']) ? trim($_POST['phone']) : '';
    $assunto = isset($_POST['subject']) ? trim($_POST['subject']) : '';
    $mensagem = isset($_POST['message']) ? trim($_POST['message']) : '';

    // Validar campos obrigatórios
    if (empty($nome) || empty($email) || empty($telefone) || empty($assunto) || empty($mensagem)) {
        echo json_encode(['success' => false, 'message' => 'Todos os campos são obrigatórios.']);
        exit;
    }

    // Validar email
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo json_encode(['success' => false, 'message' => 'E-mail inválido.']);
        exit;
    }

    // Sanitizar entradas (para evitar vulnerabilidades ao exibir em HTML, por exemplo)
    $nomeSan = htmlspecialchars($nome, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    $telefoneSan = htmlspecialchars($telefone, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    $assuntoSan = htmlspecialchars($assunto, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    $mensagemSan = htmlspecialchars($mensagem, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');

    // 3. Inserir no banco
    $stmt = $conn->prepare("INSERT INTO contatos (nome, email, telefone, assunto, mensagem) 
                            VALUES (:nome, :email, :telefone, :assunto, :mensagem)");
    $stmt->execute([
        ':nome' => $nomeSan,
        ':email' => $email,
        ':telefone' => $telefoneSan,
        ':assunto' => $assuntoSan,
        ':mensagem' => $mensagemSan
    ]);

    // 4. Enviar e-mail (opcional)
    $to = "contato@metalvidros.com.br";
    $emailSubject = "Novo contato: " . $assuntoSan;
    $emailMessage = "Nome: $nomeSan\nEmail: $email\nTelefone: $telefoneSan\n\nMensagem:\n$mensagemSan";
    $headers = "From: $email";

    if (mail($to, $emailSubject, $emailMessage, $headers)) {
        echo json_encode(['success' => true, 'message' => 'Mensagem enviada com sucesso!']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Erro ao enviar o e-mail.']);
    }

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Erro no banco de dados: ' . $e->getMessage()]);
}
?>
