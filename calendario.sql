CREATE PROCEDURE sp_select_calendario
@date_filter VARCHAR(200)
--sp_select_calendario '21/08/1999'
AS
BEGIN
	
	--Seta o formato da date
	SET DATEFORMAT dMy
		
	--Primeiro dia do mês
	DECLARE @date_start DATE = '01/' + CONVERT(VARCHAR(2), MONTH(@date_filter)) + '/' + CONVERT(VARCHAR(4), YEAR(@date_filter))

	--Último dia do mês
	DECLARE @date_end DATE = (SELECT DATEADD(DAY, -1, DATEADD(MONTH, 1, @date_start)))	
	
	--Data atual (primeiro dia do mês)
	DECLARE @current_date DATE = @date_start

	--Quantidade de semanas no mês
	DECLARE @count_week INT = (SELECT DATEDIFF(WEEK, @date_start, @date_end) + 1)	
		
	--Declara tabela calendário
	DECLARE @tb_calendar TABLE(
		week INT,
		sunday INT, 
		monday INT,
		tuesday INT,
		wednesday INT,
		thursday INT,
		friday INT,
		saturday INT)

	--Insere na @tb_calendar as semanas do mês
	DECLARE @i INT = 1
	WHILE @i <= @count_week
	BEGIN

		INSERT INTO @tb_calendar (
			week)
		SELECT 
			@i

		SET @i += 1

	END

	--Variável auxiliar que conta as semanas
	DECLARE @current_week INT = 1

	--Percorre os dias do mês
	WHILE DATEDIFF(DAY, @current_date, @date_end) >= 0
	BEGIN		

		--Atualiza conforme o dia da semana, começando da semana 1
		UPDATE @tb_calendar SET		
			sunday = CASE ISNULL(sunday, -1) WHEN -1 THEN CASE DATEPART(WEEKDAY, @current_date) WHEN 1 THEN DATEPART(DAY, @current_date) END ELSE sunday END,
			monday = CASE ISNULL(monday, -1) WHEN -1 THEN CASE DATEPART(WEEKDAY, @current_date) WHEN 2 THEN DATEPART(DAY, @current_date) END ELSE monday END,
			tuesday = CASE ISNULL(tuesday, -1) WHEN -1 THEN CASE DATEPART(WEEKDAY, @current_date) WHEN 3 THEN DATEPART(DAY, @current_date) END ELSE tuesday END,
			wednesday = CASE ISNULL(wednesday, -1) WHEN -1 THEN CASE DATEPART(WEEKDAY, @current_date) WHEN 4 THEN DATEPART(DAY, @current_date) END ELSE wednesday END,
			thursday = CASE ISNULL(thursday, -1) WHEN -1 THEN CASE DATEPART(WEEKDAY, @current_date) WHEN 5 THEN DATEPART(DAY, @current_date) END ELSE thursday END,
			friday = CASE ISNULL(friday, -1) WHEN -1 THEN CASE DATEPART(WEEKDAY, @current_date) WHEN 6 THEN DATEPART(DAY, @current_date) END ELSE friday END,
			saturday = CASE ISNULL(saturday, -1) WHEN -1 THEN CASE DATEPART(WEEKDAY, @current_date) WHEN 7 THEN DATEPART(DAY, @current_date) END ELSE saturday END
		WHERE WEEK = @current_week

		--Caso o dia atual seja sábado, soma +1 no contador de semana
		IF (SELECT DATEPART(WEEKDAY, @current_date)) = 7
		BEGIN
			SET @current_week += 1
		END

		--Soma o dia
		SET @current_date = (SELECT DATEADD(DAY, 1, @current_date))		

	END

	--Seleciona os dados
	SELECT 
		CHAR(13) + CHAR(10) + CONVERT(VARCHAR(20), sunday) + CHAR(13) + CHAR(10) AS [Domingo],
		CHAR(13) + CHAR(10) + CONVERT(VARCHAR(20), monday) + CHAR(13) + CHAR(10) AS [Segunda-feira],
		CHAR(13) + CHAR(10) + CONVERT(VARCHAR(20), tuesday) + CHAR(13) + CHAR(10) AS [Terça-feira],
		CHAR(13) + CHAR(10) + CONVERT(VARCHAR(20), wednesday) + CHAR(13) + CHAR(10) AS [Quarta-feira],
		CHAR(13) + CHAR(10) + CONVERT(VARCHAR(20), thursday) + CHAR(13) + CHAR(10) AS [Quinta-feira],
		CHAR(13) + CHAR(10) + CONVERT(VARCHAR(20), friday) + CHAR(13) + CHAR(10) AS [Sexta-feira],
		CHAR(13) + CHAR(10) + CONVERT(VARCHAR(20), saturday) + CHAR(13) + CHAR(10) AS [Sábado]
	FROM @tb_calendar

END