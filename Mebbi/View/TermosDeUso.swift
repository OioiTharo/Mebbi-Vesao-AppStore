import SwiftUI

struct TermosDeUso: View {
    var body: some View {
        ScrollView{
            HStack{
                Text("Termos de Uso do Aplicativo")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.azulPrincipal)
                Spacer()
            }.padding(.bottom, 10)
            Text(
        """
        1. Aceitação dos Termos
        Ao utilizar o aplicativo Mebbi, você concorda com os seguintes Termos de Uso. Este documento foi elaborado para garantir a transparência e definir os direitos e responsabilidades dos desenvolvedores e dos usuários.
        
        2. Descrição do Serviço
        Mebbi é um aplicativo desenvolvido por um time de 4 desenvolvedores e 1 designer com o objetivo de permitir que os usuários criem, editem e armazenem suas anotações e flashcards. As funcionalidades incluem:
        
        •    Criação de anotações com um editor de texto.
        •    Organização de anotações em categorias criadas pelo próprio usuário.
        •    Criação e gerenciamento de flashcards vinculados a cada anotação.
        •    Escolha de intervalos de repetição espaçada para revisar anotações, com as opções: 1-3-7 dias, 1-7-30 dias, e 2-4-8-16 dias.
        •    Envio de notificações de lembretes para revisar as anotações conforme a repetição espaçada escolhida.
        
        3. Permissão de Notificação
        No primeiro acesso ao app, o usuário será solicitado a conceder permissão para o envio de notificações. A permissão para notificações é necessária para que o app envie lembretes conforme as repetições espaçadas selecionadas pelo usuário.
        
        4. Armazenamento e Persistência de Dados
        O Mebbi utiliza a persistência de dados por meio de UserDefaults. Isso significa que todas as informações criadas e armazenadas pelos usuários (anotações, categorias e flashcards) são mantidas localmente no dispositivo do próprio. Não utilizamos servidores, Core Data ou SwiftData para armazenamento de dados.
        
        5. Funcionalidades de Criação e Gerenciamento
        O aplicativo permite que os usuários:
        •    Criem, editem e excluam anotações e categorias de acordo com suas necessidades.
        •    Criem e gerenciem flashcards que estão vinculados a cada anotação.
        •    Selecionem e modifiquem as opções de repetição espaçada conforme desejado.
        
        6. Privacidade e Segurança dos Dados
        Como o Mebbi utiliza apenas UserDefaults para armazenamento de dados, as informações permanecem no dispositivo do usuário e não são transmitidas para servidores externos. Os desenvolvedores não têm acesso aos dados pessoais ou conteúdos armazenados pelos usuários.
        
        7. Responsabilidades do Usuário
        O usuário é responsável por garantir que seu dispositivo esteja protegido por medidas de segurança adequadas, como senhas e autenticação biométrica, para evitar o acesso não autorizado às suas anotações e flashcards.
        
        8. Limitação de Responsabilidade
        Os desenvolvedores do Mebbi não se responsabilizam por perdas ou danos que possam ocorrer devido ao uso do aplicativo, incluindo, mas não se limitando a, perda de dados, falhas de dispositivo ou outros problemas relacionados ao armazenamento de informações no dispositivo.
        
        9. Alterações nos Termos de Uso
        Os desenvolvedores do Mebbi reservam-se o direito de modificar estes Termos de Uso a qualquer momento. Os usuários serão notificados de quaisquer alterações substanciais por meio do aplicativo.
        
        10. Contato
        Caso tenha dúvidas ou preocupações sobre esta Política de Privacidade, entre em contato com a equipe de desenvolvimento do Mebbi pelo e-mail: appmebbi@gmail.com 
        """
            )
        }
        .padding(.horizontal,20)
        .padding(.top,20)
    }
}

#Preview {
    TermosDeUso()
}
