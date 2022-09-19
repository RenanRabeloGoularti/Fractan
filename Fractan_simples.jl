using Images # Importa o pacote para criação de imagens

function principal()::Nothing
    resolucao::NTuple{2, Int64} = (512, 512) # Tamanho da imagem em pixels
    nome::String = "Curva de Levy" # Nome do arquivo que será salvo
    iteracoes::Int64 = 20 # Tamanho da árvore de pontos (cuidado, aumenta exponencialmente)
    fractal::Vector{NTuple{4, Float64}} = 
    [
        (0.5, 0.5, 0.2, 0.0)
        (0.5, -0.5, -0.2, 0.0)
    ] # Funções do SCI.
    # A primeira entrada não é o valor de 'k' e a segunda não é o de 'theta'!
    # A primeira entrada é o valor de 'k*cos(theta)' e a segunda 'k*sin(theta)'
    # Não se confunda com o que está no relatório!

    densidade::Matrix{Int64} = zeros(Int64, resolucao) # Frequência dos pontos

    fator::Float64 = Float64(min(resolucao[1], resolucao[2])) # Necessário para marcar os pontos
    nF::Int64 = length(fractal)

    p::Int64 = 2 # Posição do ponteiro (não é um ponteiro de memória)
    posicao::Vector{Int64} = ones(Int64, iteracoes) # Armazena qual o endereço do ponto que está sendo marcado
    pontos::Matrix{Float64} = zeros(Float64, (iteracoes, 2)) # Armazena os pontos calculados

    while p > 1 
        if p > iteracoes # Caso estamos indo além da profundidade que queríamos
            p -= 1 # Retorna uma posição
            x::Int64 = trunc(Int64, fator*(pontos[p,1]) + Float64(resolucao[2])*0.5)
            y::Int64 = trunc(Int64, fator*(-pontos[p,2]) + Float64(resolucao[1])*0.5)
            # Mapeia os pontos para a imagem
            if x >= 1 && x <= resolucao[2] && y >= 1 && y <= resolucao[1]
                densidade[y,x] += 1
            end # Marca onde o ponto cai
            posicao[p] += 1 # Vai para a próximo ponto
        elseif posicao[p] > nF # Se estivermos tentando calcular uma função que não existe
            posicao[p] = 1 # Volte para a primeira
            p -= 1
            posicao[p] += 1
        else
            pontos[p, 1] = fractal[posicao[p]][1]*pontos[p - 1, 1] + fractal[posicao[p]][2]*pontos[p - 1, 2] + fractal[posicao[p]][3]
            pontos[p, 2] = fractal[posicao[p]][1]*pontos[p - 1,2] - fractal[posicao[p]][2]*pontos[p - 1, 1] + fractal[posicao[p]][4]
            # Calcula o ponto baseado nas funções e armazena
            p += 1 # Avança uma posição
        end
    end

    imagem::Matrix{N0f8} = zeros(N0f8, resolucao)

    nitidez::Float64 = 1.0/maximum(densidade) # Necessário para o fractal ficar nítido

    for y::Int64 in 1:resolucao[1] 
        for x::Int64 in 1:resolucao[2]
            if densidade[y,x]*nitidez <= 1.0
                imagem[y,x] = N0f8(Float64(densidade[y,x])*nitidez)
            else
                imagem[y,x] = 1.0
            end
        end
    end  # Marca os pixels na imagem com a sua nitidez baseada na frequência de pontos 

    save("$(nome).png", imagem)

    return nothing

end

@time principal() # Executa a função e retorna o tempo decorrido e a memória alocada