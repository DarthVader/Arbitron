USE Arbitron
GO
EXEC sp_configure 'show advanced options', 1
RECONFIGURE;
EXEC sp_configure 'clr strict security', 0;
RECONFIGURE;
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;

/****** Object:  SqlAssembly [AggregateStrings]    Script Date: 04.09.2018 21:04:53 ******/
CREATE ASSEMBLY [AggregateStrings]
FROM 0x4D5A90000300000004000000FFFF0000B800000000000000400000000000000000000000000000000000000000000000000000000000000000000000800000000E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F742062652072756E20696E20444F53206D6F64652E0D0D0A2400000000000000504500004C010300559573580000000000000000E00002210B010B00000A00000006000000000000DE2800000020000000400000000000100020000000020000040000000000000006000000000000000080000000020000000000000300608500001000001000000000100000100000000000001000000000000000000000008C2800004F00000000400000C802000000000000000000000000000000000000006000000C000000542700001C0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000080000000000000000000000082000004800000000000000000000002E74657874000000E408000000200000000A000000020000000000000000000000000000200000602E72737263000000C80200000040000000040000000C0000000000000000000000000000400000402E72656C6F6300000C0000000060000000020000001000000000000000000000000000004000004200000000000000000000000000000000C02800000000000048000000020005000C2100004806000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003202730700000A7D010000042AA20F01280800000A2C012A027B010000040F01280900000A6F0A00000A72010000706F0A00000A262A52027B010000040F017B010000046F0B00000A262A00133004003D000000010000117E0C00000A0A027B010000042C28027B010000046F0D00000A16311A027B0100000416027B010000046F0D00000A17596F0E00000A0A06730F00000A2A4A02036F1000000A731100000A7D010000042A4A03027B010000046F1200000A6F1300000A2A0042534A4201000100000000000C00000076342E302E33303331390000000005006C00000018020000237E000084020000A802000023537472696E6773000000002C050000080000002355530034050000100000002347554944000000440500000401000023426C6F620000000000000002000001571702000900000000FA25330016000001000000110000000200000001000000060000000400000001000000130000000400000001000000010000000200000000000A000100000000000600400039000A007100560006008E0082000A00C900B4000600F800EE0006000A01EE00060040012D011F00540100000600890169010600A90169010600D80139000A00EE0156000A000F02560006003502160206004B02160206007202390006009E0239000000000001000000000001000100092110001F00000005000100010001009C000A005020000000008600AF000E0001005D20000000008600D300120001008620000000008600DE00180002009C20000000008600E4001E000300E52000000000E601050123000300F82000000000E601170129000400000001001D01000001002301000001002901000001002B0102000900390063012F00490063013500510063010E00590063010E00610063013A0071006301A200190063010E0021005602A80021006102AC0019006B02B00019006B02B60081007902BC0019007F02BF0019008A02C30021006301C90029009302AC0019006301C90089008A02AC0031001701C9002E000B00D2002E001300DB002E001B00E40043002B004000CE00048000000000000000000000000000000000C7010000040000000000000000000000010030000000000004000000000000000000000001004A000000000000000000003C4D6F64756C653E00636F6C756D6E5F746F5F737472696E672E646C6C00416767726567617465537472696E6773006D73636F726C69620053797374656D0056616C7565547970650053797374656D2E44617461004D6963726F736F66742E53716C5365727665722E536572766572004942696E61727953657269616C697A650053797374656D2E5465787400537472696E674275696C64657200696E7465726D656469617465526573756C7400496E69740053797374656D2E446174612E53716C54797065730053716C537472696E6700416363756D756C617465004D65726765005465726D696E6174650053797374656D2E494F0042696E61727952656164657200526561640042696E6172795772697465720057726974650056616C75650047726F7570007200770053797374656D2E446961676E6F73746963730044656275676761626C6541747472696275746500446562756767696E674D6F646573002E63746F720053797374656D2E52756E74696D652E436F6D70696C6572536572766963657300436F6D70696C6174696F6E52656C61786174696F6E734174747269627574650052756E74696D65436F6D7061746962696C69747941747472696275746500636F6C756D6E5F746F5F737472696E670053657269616C697A61626C654174747269627574650053716C55736572446566696E656441676772656761746541747472696275746500466F726D61740053797374656D2E52756E74696D652E496E7465726F705365727669636573005374727563744C61796F7574417474726962757465004C61796F75744B696E64006765745F49734E756C6C006765745F56616C756500417070656E6400537472696E6700456D707479006765745F4C656E67746800546F537472696E670052656164537472696E67004F626A6563740000000000032C0000000000CBBBCC3EB2F62B40A73EC9F99D9793320008B77A5C561934E0890306120D03200001052001011111052001011108042000111105200101121505200101121905200101112104200101080520010111356101000200000004005402124973496E76617269616E74546F4E756C6C73015402174973496E76617269616E74546F4475706C696361746573005402124973496E76617269616E74546F4F726465720054080B4D61784279746553697A65FFFFFFFF05200101113D032000020320000E052001120D0E052001120D1C02060E032000080520020E0808042001010E0307010E0801000200000000000801000800000000001E01000100540216577261704E6F6E457863657074696F6E5468726F77730100000000005595735800000000020000001C010000702700007009000052534453B2B075B831614943BD08A9FAFCD9DB7E01000000633A5C50524F475C636F6C756D6E5F746F5F737472696E675C636F6C756D6E5F746F5F737472696E675C6F626A5C52656C656173655C636F6C756D6E5F746F5F737472696E672E706462000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000B42800000000000000000000CE280000002000000000000000000000000000000000000000000000C0280000000000000000000000005F436F72446C6C4D61696E006D73636F7265652E646C6C0000000000FF25002000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001001000000018000080000000000000000000000000000001000100000030000080000000000000000000000000000001000000000048000000584000006C02000000000000000000006C0234000000560053005F00560045005200530049004F004E005F0049004E0046004F0000000000BD04EFFE00000100000000000000000000000000000000003F000000000000000400000002000000000000000000000000000000440000000100560061007200460069006C00650049006E0066006F00000000002400040000005400720061006E0073006C006100740069006F006E00000000000000B004CC010000010053007400720069006E006700460069006C00650049006E0066006F000000A801000001003000300030003000300034006200300000002C0002000100460069006C0065004400650073006300720069007000740069006F006E000000000020000000300008000100460069006C006500560065007200730069006F006E000000000030002E0030002E0030002E00300000004C001500010049006E007400650072006E0061006C004E0061006D006500000063006F006C0075006D006E005F0074006F005F0073007400720069006E0067002E0064006C006C00000000002800020001004C006500670061006C0043006F0070007900720069006700680074000000200000005400150001004F0072006900670069006E0061006C00460069006C0065006E0061006D006500000063006F006C0075006D006E005F0074006F005F0073007400720069006E0067002E0064006C006C0000000000340008000100500072006F006400750063007400560065007200730069006F006E00000030002E0030002E0030002E003000000038000800010041007300730065006D0062006C0079002000560065007200730069006F006E00000030002E0030002E0030002E003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000C000000E03800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
WITH PERMISSION_SET = SAFE
GO


/****** Object:  UserDefinedAggregate [dbo].[AggregateStrings]    Script Date: 04.09.2018 21:04:40 ******/
CREATE AGGREGATE [dbo].[AggregateStrings]
(@input [nvarchar](200))
RETURNS[nvarchar](max)
EXTERNAL NAME [AggregateStrings].[AggregateStrings]
GO


