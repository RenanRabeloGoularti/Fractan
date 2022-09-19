using Images # Importa o pacote para criação de imagens

function principal()::Nothing
    resolucao::NTuple{2, Int64} = (512, 512) # Tamanho da imagem em pixels
    nome::String = "Curva de Lévy" # Nome do arquivo que será salvo
    iteracoes::Int64 = 20 # Tamanho da árvore de pontos (cuidado, aumenta exponencialmente)
    fractal::Vector{NTuple{4, Float64}} = 
    [
        (0.5, 0.5, 0.2, 0.0)
        (0.5, -0.5, -0.2, 0.0)
    ] # Funções do SCI.
    # A primeira entrada não é o valor de 'k' e a segunda não é o de 'theta'!
    # A primeira entrada é o valor de 'k*cos(theta)' e a segunda 'k*sin(theta)'
    # Não se confunda com o que está no relatório!

    imagem::Matrix{N0f8} = zeros(N0f8, resolucao)
    fator::Float64 = Float64(min(resolucao[1], resolucao[2])) # Necessário para marcar os pontos
    nF::Int64 = length(fractal)

    posicao::Vector{Int64} = ones(Int64, iteracoes) # Armazena qual o endereço do ponto que será calculado
    ponto::Vector{Float64} = [0.0, 0.0]

    for n::Int64 in 1:(nF^iteracoes)
        
        for i::Int64 in posicao
            h::Float64 = ponto[1]
            ponto[1] = fractal[i][1]*ponto[1] + fractal[i][2]*ponto[2] + fractal[i][3]
            ponto[2] = fractal[i][1]*ponto[2] - fractal[i][2]*h + fractal[i][4]
        end  # Calcula o valor de ponto baseado na expansão

        x::Int64 = trunc(Int64, fator*(ponto[1]) + Float64(resolucao[2])*0.5)
        y::Int64 = trunc(Int64, fator*(-ponto[2]) + Float64(resolucao[1])*0.5)
        # Mapeia os pontos para a imagem

        if x >= 1 && x <= resolucao[2] && y >= 1 && y <= resolucao[1]
            if imagem[y,x] + 0.004 > 1.0
                imagem[y,x] = 1.0
            else
                imagem[y,x] += 0.004
            end
        end # Marca onde o ponto cai

        p::Int64 = iteracoes

        posicao[p] += 1

        while true
            if p == 0
                break
            elseif posicao[p] == nF + 1
                posicao[p] = 1
                p -= 1
                if p == 0
                    break
                end
                posicao[p] += 1
            else
                break
            end
        end # Calcula a expansão do número sem redundâncias
    end

    save("$(nome).png", imagem)

    return nothing

end

@time principal() # Executa a função e retorna o tempo decorrido e a memória alocada
