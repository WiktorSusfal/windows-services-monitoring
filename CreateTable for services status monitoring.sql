

/****** Object:  Table [dbo].[ServicesStatus]    Script Date: 2022-02-17 14:04:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ServicesStatus](
	[MachineName] [varchar](100) NOT NULL,
	[ServiceName] [varchar](100) NOT NULL,
	[DisplayName] [nvarchar](500) NULL,
	[SrvStatus] [varchar](50) NULL,
	[RefreshDate] [varchar](30) NULL
) ON [PRIMARY]
GO


