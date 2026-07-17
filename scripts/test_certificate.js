// Script de teste para geração de certificados
// Este script deve ser executado com: node scripts/test_certificate.js

import { createClient } from '@supabase/supabase-js';
import { jsPDF } from 'jspdf';
import dotenv from 'dotenv';

dotenv.config();

const SUPABASE_URL = process.env.VITE_SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.VITE_SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('ERRO: VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY são obrigatórios no .env');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const testStudentData = {
  name: 'Aluno Teste',
  email: 'teste@example.com'
};

const testCourseData = {
  title: 'Curso de Treinamento Garmin',
  duration: '10 horas',
  completionDate: new Date().toLocaleDateString('pt-BR')
};

async function generateAndSaveCertificate(studentData, courseData) {
  try {
    // Criar documento PDF (A4 landscape)
    const doc = new jsPDF({
      orientation: 'landscape',
      unit: 'mm',
      format: 'a4'
    });

    const pageWidth = doc.internal.pageSize.getWidth();
    const pageHeight = doc.internal.pageSize.getHeight();

    // Fundo branco
    doc.setFillColor(255, 255, 255);
    doc.rect(0, 0, pageWidth, pageHeight, 'F');

    // Borda decorativa
    doc.setDrawColor(0, 122, 106);
    doc.setLineWidth(3);
    doc.rect(10, 10, pageWidth - 20, pageHeight - 20);

    // Borda interna
    doc.setDrawColor(0, 122, 106);
    doc.setLineWidth(1);
    doc.rect(15, 15, pageWidth - 30, pageHeight - 30);

    // Título "CERTIFICADO"
    doc.setFontSize(36);
    doc.setTextColor(0, 122, 106);
    doc.setFont('helvetica', 'bold');
    doc.text('CERTIFICADO', pageWidth / 2, 40, { align: 'center' });

    // Subtítulo
    doc.setFontSize(14);
    doc.setTextColor(100, 100, 100);
    doc.setFont('helvetica', 'normal');
    doc.text('Certificamos que', pageWidth / 2, 60, { align: 'center' });

    // Nome do aluno
    doc.setFontSize(28);
    doc.setTextColor(0, 0, 0);
    doc.setFont('helvetica', 'bold');
    doc.text(studentData.name || 'Nome do Aluno', pageWidth / 2, 80, { align: 'center' });

    // Texto de conclusão
    doc.setFontSize(14);
    doc.setTextColor(100, 100, 100);
    doc.setFont('helvetica', 'normal');
    doc.text('concluiu com êxito o curso', pageWidth / 2, 100, { align: 'center' });

    // Nome do curso
    doc.setFontSize(24);
    doc.setTextColor(0, 122, 106);
    doc.setFont('helvetica', 'bold');
    doc.text(courseData.title || 'Nome do Curso', pageWidth / 2, 125, { align: 'center' });

    // Carga horária
    if (courseData.duration) {
      doc.setFontSize(14);
      doc.setTextColor(100, 100, 100);
      doc.setFont('helvetica', 'normal');
      doc.text(`Carga horária: ${courseData.duration}`, pageWidth / 2, 145, { align: 'center' });
    }

    // Data de conclusão
    const completionDate = courseData.completionDate || new Date().toLocaleDateString('pt-BR');
    doc.setFontSize(14);
    doc.setTextColor(100, 100, 100);
    doc.setFont('helvetica', 'normal');
    doc.text(`Concluído em: ${completionDate}`, pageWidth / 2, 165, { align: 'center' });

    // Rodapé com ID do certificado
    const certificateId = `CERT-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    doc.setFontSize(10);
    doc.setTextColor(150, 150, 150);
    doc.setFont('helvetica', 'normal');
    doc.text(`ID: ${certificateId}`, pageWidth / 2, pageHeight - 20, { align: 'center' });

    // Gerar blob do PDF
    const pdfBlob = doc.output('blob');

    // Nome do arquivo
    const fileName = `${studentData.name.replace(/\s+/g, '_')}_${courseData.title.replace(/\s+/g, '_')}_${certificateId}.pdf`;

    // Upload para o Supabase Storage
    const filePath = `certificates/${fileName}`;
    const { data, error } = await supabase.storage
      .from('certificates')
      .upload(filePath, pdfBlob, {
        contentType: 'application/pdf',
        upsert: false
      });

    if (error) {
      throw new Error(`Erro ao fazer upload do certificado: ${error.message}`);
    }

    // Obter URL pública do arquivo
    const { data: { publicUrl } } = supabase.storage
      .from('certificates')
      .getPublicUrl(filePath);

    return publicUrl;
  } catch (err) {
    console.error('[CertificateService] erro ao gerar certificado:', err);
    throw err;
  }
}

async function testCertificateGeneration() {
  console.log('Iniciando teste de geração de certificado...');
  console.log('Dados do aluno:', testStudentData);
  console.log('Dados do curso:', testCourseData);
  
  try {
    const certificateUrl = await generateAndSaveCertificate(testStudentData, testCourseData);
    console.log('\n✓ Certificado gerado com sucesso!');
    console.log('URL do certificado:', certificateUrl);
  } catch (err) {
    console.error('\n✗ Erro ao gerar certificado:', err.message);
    process.exit(1);
  }
}

testCertificateGeneration();
