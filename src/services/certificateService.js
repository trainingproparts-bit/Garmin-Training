// src/services/certificateService.js
// Serviço para geração e salvamento de certificados PDF
// Gera certificados usando jsPDF e faz upload para o bucket 'certificates' do Supabase

import { jsPDF } from 'jspdf';
import { supabase } from '../config/supabase.js';

/**
 * Gera um certificado PDF e faz upload para o Supabase Storage
 * @param {Object} studentData - Dados do aluno { name, email }
 * @param {Object} courseData - Dados do curso { title, duration, completionDate }
 * @returns {Promise<string>} - URL do certificado no Supabase
 */
export async function generateAndSaveCertificate(studentData, courseData) {
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
    doc.setDrawColor(140, 31, 46); // Vermelho-vinho (paleta cinza/vermelho)
    doc.setLineWidth(3);
    doc.rect(10, 10, pageWidth - 20, pageHeight - 20);

    // Borda interna
    doc.setDrawColor(140, 31, 46);
    doc.setLineWidth(1);
    doc.rect(15, 15, pageWidth - 30, pageHeight - 30);

    // Título "CERTIFICADO"
    doc.setFontSize(36);
    doc.setTextColor(140, 31, 46);
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
    doc.setTextColor(140, 31, 46);
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

/**
 * Lista certificados de um aluno
 * @param {string} studentEmail - Email do aluno
 * @returns {Promise<Array>} - Lista de certificados
 */
export async function listStudentCertificates(studentEmail) {
  try {
    const { data, error } = await supabase.storage
      .from('certificates')
      .list(`certificates`, {
        search: studentEmail
      });

    if (error) throw error;
    return data || [];
  } catch (err) {
    console.error('[CertificateService] erro ao listar certificados:', err);
    throw err;
  }
}
