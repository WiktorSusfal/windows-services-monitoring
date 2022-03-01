

/****** Object:  StoredProcedure [dbo].[StoppedServices_SendMails]    Script Date: 2022-02-17 13:59:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StoppedServices_SendMails]
	-- Add the parameters for the stored procedure here
	@dbMAilProfile varchar(100)
	,@mailRecipients VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @machine nvarchar(100)
		, @service nvarchar(100)
		, @status nvarchar(50)

		, @mbody NVARCHAR(MAX) = N'<p>LIST OF NON RUNNING SERVICES:</p><br><p>[MACHINE NAME], [SERVICE NAME], [SERVICE STATE]</p><br><br><ul>'

	
	
	IF EXISTS( SELECT MachineName, ServiceName, SrvStatus FROM dbo.ServicesStatus WHERE SrvStatus != 'Running' )
	BEGIN
			DECLARE SRV CURSOR FOR
			SELECT MachineName, ServiceName, SrvStatus FROM dbo.ServicesStatus WHERE SrvStatus != 'Running'

			OPEN SRV
			FETCH NEXT FROM SRV INTO @machine, @service, @status

			WHILE @@FETCH_STATUS = 0
			BEGIN 
			
					SET @mbody = @mbody + N'<li>' + @machine + N', ' + @service + N', ' + @status + N'</li>';
			
					FETCH NEXT FROM SRV INTO @machine, @service, @status
			END

			SET @mbody = @mbody + N'</ul>';

			EXEC msdb.dbo.sp_send_dbmail
						@profile_name = @dbMAilProfile,  
						@recipients = @mailRecipients, 
						@body = @mbody,
						@body_format ='HTML',
						@subject = N'List of non running services';
	
			CLOSE SRV
			DEALLOCATE SRV
	END
END
GO


